import { useMemo } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { isSupabaseConfigured } from "@/lib/env";
import { getSupabaseClient } from "@/lib/supabase";
import type { SignalConcept } from "../schemas/concept.schema";
import { createLocalConceptRepository } from "../services/local-concept-repository";
import { createSupabaseConceptRepository } from "../services/supabase-concept-repository";
import {
  conceptsQueryKey,
  orderConcepts,
  type ConceptsBackend,
  type SignalConceptRepository,
} from "../services/concept-repository";

type ConceptsQueryData = {
  backend: ConceptsBackend;
  degradedReason: string | null;
  concepts: SignalConcept[];
};

type UseConceptsOptions = {
  fallbackRepository?: SignalConceptRepository;
  primaryRepository?: SignalConceptRepository;
  supabaseConfigured?: boolean;
};

async function loadConceptsData(
  supabaseConfigured: boolean,
  primaryRepository: SignalConceptRepository,
  fallbackRepository: SignalConceptRepository
): Promise<ConceptsQueryData> {
  if (!supabaseConfigured) {
    return {
      concepts: await fallbackRepository.list(),
      backend: "local-fallback",
      degradedReason: null,
    };
  }

  try {
    return {
      concepts: await primaryRepository.list(),
      backend: "supabase",
      degradedReason: null,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to reach the configured remote backend.";

    return {
      concepts: await fallbackRepository.list(),
      backend: "local-fallback",
      degradedReason: message,
    };
  }
}

export function useConcepts(options: UseConceptsOptions = {}) {
  const queryClient = useQueryClient();
  const supabaseConfigured = options.supabaseConfigured ?? isSupabaseConfigured();
  const fallbackRepository = useMemo(
    () => options.fallbackRepository ?? createLocalConceptRepository(),
    [options.fallbackRepository]
  );
  const primaryRepository = useMemo(
    () =>
      options.primaryRepository ??
      (supabaseConfigured
        ? createSupabaseConceptRepository(getSupabaseClient())
        : fallbackRepository),
    [fallbackRepository, options.primaryRepository, supabaseConfigured]
  );

  const query = useQuery({
    queryKey: conceptsQueryKey,
    queryFn: () => loadConceptsData(supabaseConfigured, primaryRepository, fallbackRepository),
    refetchOnWindowFocus: false,
  });

  const mutation = useMutation({
    mutationFn: async (concept: SignalConcept) => {
      if (query.data?.backend === "local-fallback") {
        return {
          concept: await fallbackRepository.save(concept),
          backend: "local-fallback" as const,
          degradedReason: query.data.degradedReason,
        };
      }

      try {
        return {
          concept: await primaryRepository.save(concept),
          backend: "supabase" as const,
          degradedReason: null,
        };
      } catch (error) {
        const message = error instanceof Error ? error.message : "Failed to save the concept remotely.";

        return {
          concept: await fallbackRepository.save(concept),
          backend: "local-fallback" as const,
          degradedReason: message,
        };
      }
    },
    onSuccess: (nextData) => {
      queryClient.setQueryData<ConceptsQueryData | undefined>(conceptsQueryKey, (currentData) => {
        const currentConcepts = currentData?.concepts ?? [];
        return {
          backend: nextData.backend,
          degradedReason: nextData.degradedReason,
          concepts: orderConcepts([
            nextData.concept,
            ...currentConcepts.filter((concept) => concept.id !== nextData.concept.id),
          ]),
        };
      });
    },
  });

  return {
    concepts: query.data?.concepts ?? [],
    backend: query.data?.backend ?? (supabaseConfigured ? "supabase" : "local-fallback"),
    degradedReason: query.data?.degradedReason ?? null,
    isLoading: query.isLoading,
    isSaving: mutation.isPending,
    error:
      mutation.error instanceof Error
        ? mutation.error
        : query.error instanceof Error
          ? query.error
          : null,
    saveConcept: mutation.mutateAsync,
  };
}

