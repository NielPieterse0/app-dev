import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type React from "react";
import { renderHook, waitFor } from "@testing-library/react";
import { describe, expect, test, vi } from "vitest";
import { useSourceSettings } from "../hooks/useSourceSettings";
import type { SourceSettingsRepository } from "../services/source-settings-repository";

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
      mutations: {
        retry: false,
      },
    },
  });

  return {
    queryClient,
    wrapper: ({ children }: { children: React.ReactNode }) => (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    ),
  };
}

describe("useSourceSettings", () => {
  test("hydrates from the configured repository", async () => {
    const primaryRepository: SourceSettingsRepository = {
      get: vi.fn().mockResolvedValue({
        enabledSources: ["github"],
        includeKeywords: ["agents"],
      }),
      save: vi.fn(),
    };
    const fallbackRepository: SourceSettingsRepository = {
      get: vi.fn(),
      save: vi.fn(),
    };
    const { wrapper } = createWrapper();

    const { result } = renderHook(
      () =>
        useSourceSettings({
          primaryRepository,
          fallbackRepository,
          supabaseConfigured: true,
        }),
      { wrapper }
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.backend).toBe("supabase");
    expect(result.current.settings).toEqual({
      enabledSources: ["github"],
      includeKeywords: ["agents"],
    });
  });

  test("uses the local fallback when Supabase is unavailable", async () => {
    const primaryRepository: SourceSettingsRepository = {
      get: vi.fn().mockRejectedValue(new Error("project paused")),
      save: vi.fn(),
    };
    const fallbackRepository: SourceSettingsRepository = {
      get: vi.fn().mockResolvedValue({
        enabledSources: ["github", "hacker_news"],
        includeKeywords: [],
      }),
      save: vi.fn(),
    };
    const { wrapper } = createWrapper();

    const { result } = renderHook(
      () =>
        useSourceSettings({
          primaryRepository,
          fallbackRepository,
          supabaseConfigured: true,
        }),
      { wrapper }
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    expect(result.current.backend).toBe("local-fallback");
    expect(result.current.degradedReason).toContain("project paused");
  });

  test("replaces the cache on successful save", async () => {
    const primaryRepository: SourceSettingsRepository = {
      get: vi.fn().mockResolvedValue({
        enabledSources: ["github", "hacker_news"],
        includeKeywords: [],
      }),
      save: vi.fn().mockResolvedValue({
        enabledSources: ["github"],
        includeKeywords: ["agents"],
      }),
    };
    const fallbackRepository: SourceSettingsRepository = {
      get: vi.fn(),
      save: vi.fn(),
    };
    const { wrapper } = createWrapper();

    const { result } = renderHook(
      () =>
        useSourceSettings({
          primaryRepository,
          fallbackRepository,
          supabaseConfigured: true,
        }),
      { wrapper }
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    await result.current.saveSettings({
      enabledSources: ["github"],
      includeKeywords: ["agents"],
    });

    await waitFor(() =>
      expect(result.current.settings).toEqual({
        enabledSources: ["github"],
        includeKeywords: ["agents"],
      })
    );
  });

  test("preserves the last confirmed settings when save fails", async () => {
    const primaryRepository: SourceSettingsRepository = {
      get: vi.fn().mockResolvedValue({
        enabledSources: ["github", "hacker_news"],
        includeKeywords: [],
      }),
      save: vi.fn().mockRejectedValue(new Error("write failed")),
    };
    const fallbackRepository: SourceSettingsRepository = {
      get: vi.fn(),
      save: vi.fn(),
    };
    const { wrapper } = createWrapper();

    const { result } = renderHook(
      () =>
        useSourceSettings({
          primaryRepository,
          fallbackRepository,
          supabaseConfigured: true,
        }),
      { wrapper }
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    await expect(
      result.current.saveSettings({
        enabledSources: ["github"],
        includeKeywords: ["agents"],
      })
    ).rejects.toThrow("write failed");

    expect(result.current.settings).toEqual({
      enabledSources: ["github", "hacker_news"],
      includeKeywords: [],
    });
    await waitFor(() =>
      expect(result.current.error?.message).toContain("write failed")
    );
  });

  test("saves through the fallback repository when Supabase is not configured", async () => {
    const fallbackRepository: SourceSettingsRepository = {
      get: vi.fn().mockResolvedValue({
        enabledSources: ["github", "hacker_news"],
        includeKeywords: [],
      }),
      save: vi.fn().mockResolvedValue({
        enabledSources: ["github"],
        includeKeywords: ["agents"],
      }),
    };
    const { wrapper } = createWrapper();

    const { result } = renderHook(
      () =>
        useSourceSettings({
          fallbackRepository,
          supabaseConfigured: false,
        }),
      { wrapper }
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));
    await result.current.saveSettings({
      enabledSources: ["github"],
      includeKeywords: ["agents"],
    });

    expect(result.current.backend).toBe("local-fallback");
    expect(fallbackRepository.save).toHaveBeenCalledOnce();
  });
});
