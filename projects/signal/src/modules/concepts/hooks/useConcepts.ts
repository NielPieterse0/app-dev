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

type SaveConceptResult = {
  backend: ConceptsBackend;
  concept: SignalConcept;
  degradedReason: string | null;
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

function useConceptRepositories(options: UseConceptsOptions = {}) {
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

  return {
    fallbackRepository,
    primaryRepository,
    supabaseConfigured,
  };
}

export function useConcepts(options: UseConceptsOptions = {}) {
  const { fallbackRepository, primaryRepository, supabaseConfigured } =
    useConceptRepositories(options);

  const query = useQuery({
    queryKey: conceptsQueryKey,
    queryFn: () => loadConceptsData(supabaseConfigured, primaryRepository, fallbackRepository),
    refetchOnWindowFocus: false,
  });

  return {
    concepts: query.data?.concepts ?? [],
    backend: query.data?.backend ?? (supabaseConfigured ? "supabase" : "local-fallback"),
    degradedReason: query.data?.degradedReason ?? null,
    isLoading: query.isLoading,
    error: query.error instanceof Error ? query.error : null,
  };
}

export function useSaveConcept(options: UseConceptsOptions = {}) {
  const queryClient = useQueryClient();
  const { fallbackRepository, primaryRepository, supabaseConfigured } =
    useConceptRepositories(options);

  const mutation = useMutation({
    mutationFn: async (concept: SignalConcept): Promise<SaveConceptResult> => {
      const currentData = queryClient.getQueryData<ConceptsQueryData>(conceptsQueryKey);
      const saveToFallback = !supabaseConfigured || currentData?.backend === "local-fallback";

      if (saveToFallback) {
        return {
          concept: await fallbackRepository.save(concept),
          backend: "local-fallback",
          degradedReason: currentData?.degradedReason ?? null,
        };
      }

      try {
        return {
          concept: await primaryRepository.save(concept),
          backend: "supabase",
          degradedReason: null,
        };
      } catch (error) {
        const message =
          error instanceof Error ? error.message : "Failed to save the concept remotely.";

        return {
          concept: await fallbackRepository.save(concept),
          backend: "local-fallback",
          degradedReason: message,
        };
      }
    },
    onSuccess: (nextData) => {
      queryClient.setQueryData<ConceptsQueryData | undefined>(
        conceptsQueryKey,
        (currentData: ConceptsQueryData | undefined) => {
        const currentConcepts = currentData?.concepts ?? [];
        return {
          backend: nextData.backend,
          degradedReason: nextData.degradedReason,
          concepts: orderConcepts([
            nextData.concept,
            ...currentConcepts.filter((concept) => concept.id !== nextData.concept.id),
          ]),
        };
        }
      );
    },
  });

  return {
    isSaving: mutation.isPending,
    saveConcept: mutation.mutateAsync,
    error: mutation.error instanceof Error ? mutation.error : null,
  };
}
