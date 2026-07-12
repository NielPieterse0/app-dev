import { useMemo } from "react";
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
  backend: SettingsBackend;
  degradedReason: string | null;
  settings: SourceSettings;
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
  const fallbackRepository = useMemo(
    () => options.fallbackRepository ?? createLocalSourceSettingsRepository(),
    [options.fallbackRepository]
  );
  const primaryRepository = useMemo(
    () =>
      options.primaryRepository ??
      (supabaseConfigured
        ? createSupabaseSourceSettingsRepository(getSupabaseClient())
        : fallbackRepository),
    [fallbackRepository, options.primaryRepository, supabaseConfigured]
  );

  const query = useQuery({
    queryKey: sourceSettingsQueryKey,
    queryFn: () =>
      loadSettingsData(supabaseConfigured, primaryRepository, fallbackRepository),
    refetchOnWindowFocus: false,
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

      try {
        return {
          settings: await primaryRepository.save(settings),
          backend: "supabase" as const,
          degradedReason: null,
        };
      } catch (error) {
        const message =
          error instanceof Error ? error.message : "Failed to save settings to Supabase.";

        return {
          settings: await fallbackRepository.save(settings),
          backend: "local-fallback" as const,
          degradedReason: message,
        };
      }
    },
    onSuccess: (nextData) => {
      queryClient.setQueryData(sourceSettingsQueryKey, nextData);
    },
  });

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
