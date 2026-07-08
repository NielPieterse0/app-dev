import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { beforeEach, describe, expect, test, vi } from "vitest";
import {
  SettingsKeywordsRoute,
  SettingsRoute,
  SettingsSourcesRoute,
} from "../routes/SettingsRoute";

const sourcesState = {
  enabledSources: ["github", "hacker_news"] as ("github" | "hacker_news")[],
  hasHydrated: false,
  includeKeywordsText: "agents, research",
  isDirty: false,
  hydrateFromSettings: vi.fn(),
  setSourceEnabled: vi.fn(),
  setIncludeKeywordsText: vi.fn(),
};

const useSourceSettingsMock = vi.fn();

vi.mock("@/modules/sources", () => ({
  getEnabledKeywordFilters: (value: string) =>
    value
      .split(",")
      .map((entry) => entry.trim().toLowerCase())
      .filter(Boolean),
  useSourcePreferencesStore: (selector: (state: typeof sourcesState) => unknown) =>
    selector(sourcesState),
  useSourceSettings: () => useSourceSettingsMock(),
}));

function renderSettings(initialEntry = "/settings") {
  const queryClient = new QueryClient();

  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter initialEntries={[initialEntry]}>
        <Routes>
          <Route path="/settings" element={<SettingsRoute />}>
            <Route index element={<SettingsSourcesRoute />} />
            <Route path="keywords" element={<SettingsKeywordsRoute />} />
          </Route>
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>
  );
}

describe("SettingsRoute", () => {
  beforeEach(() => {
    sourcesState.enabledSources = ["github", "hacker_news"];
    sourcesState.hasHydrated = false;
    sourcesState.includeKeywordsText = "agents, research";
    sourcesState.isDirty = false;
    sourcesState.hydrateFromSettings.mockReset();
    sourcesState.setSourceEnabled.mockReset();
    sourcesState.setIncludeKeywordsText.mockReset();
    useSourceSettingsMock.mockReset();
    useSourceSettingsMock.mockReturnValue({
      settings: {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents", "research"],
      },
      backend: "supabase",
      degradedReason: null,
      isLoading: false,
      isSaving: false,
      error: null,
      saveSettings: vi.fn().mockResolvedValue({
        settings: {
          enabledSources: ["github", "hacker_news"],
          includeKeywords: ["agents", "research"],
        },
        backend: "supabase",
        degradedReason: null,
      }),
    });
  });

  test("hydrates the draft values and renders keyboard-accessible source controls", () => {
    renderSettings();

    expect(sourcesState.hydrateFromSettings).toHaveBeenCalledWith({
      enabledSources: ["github", "hacker_news"],
      includeKeywords: ["agents", "research"],
    }, { force: true });
    expect(screen.getByRole("button", { name: "Enabled GitHub" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Enabled Hacker News" })).toBeInTheDocument();
  });

  test("disables save controls during an active save", () => {
    useSourceSettingsMock.mockReturnValue({
      settings: {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents", "research"],
      },
      backend: "supabase",
      degradedReason: null,
      isLoading: false,
      isSaving: true,
      error: null,
      saveSettings: vi.fn(),
    });

    renderSettings();

    expect(screen.getByRole("button", { name: "Saving settings..." })).toBeDisabled();
  });

  test("shows save confirmation after a successful save", async () => {
    const saveSettings = vi.fn().mockResolvedValue({
      settings: {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents", "research"],
      },
      backend: "supabase",
      degradedReason: null,
    });
    useSourceSettingsMock.mockReturnValue({
      settings: {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents", "research"],
      },
      backend: "supabase",
      degradedReason: null,
      isLoading: false,
      isSaving: false,
      error: null,
      saveSettings,
    });

    renderSettings();
    fireEvent.click(screen.getByRole("button", { name: "Save source settings" }));

    await waitFor(() => expect(saveSettings).toHaveBeenCalledOnce());
  });

  test("shows a recoverable error message", () => {
    useSourceSettingsMock.mockReturnValue({
      settings: {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents", "research"],
      },
      backend: "supabase",
      degradedReason: null,
      isLoading: false,
      isSaving: false,
      error: new Error("write failed"),
      saveSettings: vi.fn(),
    });

    renderSettings();

    expect(screen.getByText("write failed")).toBeInTheDocument();
  });

  test("discloses local fallback mode", () => {
    useSourceSettingsMock.mockReturnValue({
      settings: {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents", "research"],
      },
      backend: "local-fallback",
      degradedReason: "project paused",
      isLoading: false,
      isSaving: false,
      error: null,
      saveSettings: vi.fn(),
    });

    renderSettings("/settings/keywords");

    expect(
      screen.getByText(/local fallback while Supabase is unavailable or unconfigured/i)
    ).toBeInTheDocument();
    expect(screen.getByText(/project paused/i)).toBeInTheDocument();
  });
});
