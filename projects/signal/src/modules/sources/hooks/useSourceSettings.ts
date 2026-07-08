import { useEffect } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { isSupabaseConfigured } from "../../../lib/env";
import { getSupabaseClient } from "../../../lib/supabase";
import type { SourceSettings } from "../schemas/source-item.schema";
import { createLocalSourceSettingsRepository } from "../services/local-source-settings-repository";
import { createSupabaseSourceSettingsRepository } from "../services/supabase-source-settings-repository";
import {
  defaultSourceSettings,
  sourceSettingsQueryKey,
  type SettingsBackend,
  type SourceSettingsRepository,
} from "../services/source-settings-repository";

type SourceSettingsQueryData = {
  settings: SourceSettings;
  backend: SettingsBackend;
  degradedReason: string | null;
};

type UseSourceSettingsOptions = {
  fallbackRepository?: SourceSettingsRepository;
  primaryRepository?: SourceSettingsRepository;
  supabaseConfigured?: boolean;
};

async function loadSettingsData(
  supabaseConfigured: boolean,
  primaryRepository: SourceSettingsRepository,
  fallbackRepository: SourceSettingsRepository
): Promise<SourceSettingsQueryData> {
  if (!supabaseConfigured) {
    return {
      settings: await fallbackRepository.get(),
      backend: "local-fallback",
      degradedReason: null,
    };
  }

  try {
    return {
      settings: await primaryRepository.get(),
      backend: "supabase",
      degradedReason: null,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to reach Supabase.";

    return {
      settings: await fallbackRepository.get(),
      backend: "local-fallback",
      degradedReason: message,
    };
  }
}

export function useSourceSettings(options: UseSourceSettingsOptions = {}) {
  const queryClient = useQueryClient();
  const supabaseConfigured = options.supabaseConfigured ?? isSupabaseConfigured();
  const fallbackRepository =
    options.fallbackRepository ?? createLocalSourceSettingsRepository();
  const primaryRepository =
    options.primaryRepository ??
    (supabaseConfigured
      ? createSupabaseSourceSettingsRepository(getSupabaseClient())
      : fallbackRepository);

  const query = useQuery({
    queryKey: sourceSettingsQueryKey,
    queryFn: () =>
      loadSettingsData(supabaseConfigured, primaryRepository, fallbackRepository),
  });

  const mutation = useMutation({
    mutationFn: async (settings: SourceSettings) => {
      if (query.data?.backend === "local-fallback") {
        return {
          settings: await fallbackRepository.save(settings),
          backend: "local-fallback" as const,
          degradedReason: query.data.degradedReason,
        };
      }

      return {
        settings: await primaryRepository.save(settings),
        backend: "supabase" as const,
        degradedReason: null,
      };
    },
    onSuccess: (nextData) => {
      queryClient.setQueryData(sourceSettingsQueryKey, nextData);
    },
  });

  useEffect(() => {
    if (!query.error) {
      return;
    }

    // Keep the last confirmed settings in cache when a save fails.
    queryClient.setQueryData<SourceSettingsQueryData | undefined>(
      sourceSettingsQueryKey,
      (current) => current
    );
  }, [query.error, queryClient]);

  return {
    settings: query.data?.settings ?? defaultSourceSettings,
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
    saveSettings: mutation.mutateAsync,
  };
}
