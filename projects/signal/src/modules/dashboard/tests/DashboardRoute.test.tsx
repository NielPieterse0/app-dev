import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, test, vi } from "vitest";
import { DashboardRoute } from "../routes/DashboardRoute";

const useRankedItemsMock = vi.fn();
const useDashboardViewStoreMock = vi.fn();
const useSourcePreferencesStoreMock = vi.fn();

vi.mock("../hooks/useRankedItems", () => ({
  useRankedItems: (options: unknown) => useRankedItemsMock(options),
}));

vi.mock("../state/dashboard-view-store", () => ({
  useDashboardViewStore: () => useDashboardViewStoreMock(),
}));

vi.mock("@/modules/sources", () => ({
  buildActivityPoints: vi.fn(() => []),
  getEnabledKeywordFilters: (value: string) =>
    value
      .split(",")
      .map((entry) => entry.trim().toLowerCase())
      .filter(Boolean),
  useSourcePreferencesStore: (selector: (state: { enabledSources: ["github", "hacker_news"]; includeKeywordsText: string }) => unknown) =>
    useSourcePreferencesStoreMock(selector),
}));

describe("DashboardRoute", () => {
  beforeEach(() => {
    useDashboardViewStoreMock.mockReturnValue({
      selectedSource: "all",
      setSelectedSource: vi.fn(),
    });

    useSourcePreferencesStoreMock.mockImplementation((selector) =>
      selector({
        enabledSources: ["github", "hacker_news"],
        includeKeywordsText: "",
      })
    );
  });

  test("renders a loading state", () => {
    useRankedItemsMock.mockReturnValue({
      items: [],
      backend: "local-fallback",
      degradedReason: null,
      lastRefreshedAt: null,
      isRefreshing: false,
      refreshItems: vi.fn(),
      isLoading: true,
      error: null,
    });

    render(<DashboardRoute />);

    expect(screen.getByText("Loading source signals")).toBeInTheDocument();
  });

  test("renders an empty state before the first refresh", () => {
    useRankedItemsMock.mockReturnValue({
      items: [],
      backend: "local-fallback",
      degradedReason: null,
      lastRefreshedAt: null,
      isRefreshing: false,
      refreshItems: vi.fn(),
      isLoading: false,
      error: null,
    });

    render(<DashboardRoute />);

    expect(screen.getByRole("region", { name: "No persisted signals yet" })).toBeInTheDocument();
  });

  test("renders dashboard content when data exists", () => {
    useRankedItemsMock.mockReturnValue({
      items: [
        {
          id: "github:1",
          source: "github",
          externalId: "1",
          title: "owner/repo",
          summary: "A useful repo.",
          url: "https://github.com/owner/repo",
          author: "owner",
          publishedAt: "2026-07-08T10:00:00.000Z",
          collectedAt: "2026-07-08T10:00:00.000Z",
          engagementCount: 200,
          score: 24.4,
          keywords: ["ai", "agents"],
        },
      ],
      backend: "supabase",
      degradedReason: null,
      lastRefreshedAt: "2026-07-08T10:10:00.000Z",
      isRefreshing: false,
      refreshItems: vi.fn(),
      isLoading: false,
      error: null,
    });

    render(<DashboardRoute />);

    expect(screen.getByRole("heading", { name: "Trend scout" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "owner/repo" })).toBeInTheDocument();
    expect(screen.getByText("Total signals")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Refresh live feed" })).toBeInTheDocument();
  });
});
