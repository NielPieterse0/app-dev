import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { fireEvent, render, screen } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { beforeEach, describe, expect, test, vi } from "vitest";
import { ConceptsRoute } from "../routes/ConceptsRoute";

const useConceptsMock = vi.fn();

vi.mock("../hooks/useConcepts", () => ({
  useConcepts: () => useConceptsMock(),
}));

vi.mock("@/modules/sources", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@/modules/sources")>();

  return {
    ...actual,
    sourceLabels: {
      github: "GitHub",
      hacker_news: "Hacker News",
    },
  };
});

function renderRoute() {
  const queryClient = new QueryClient();

  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter initialEntries={["/concepts"]}>
        <Routes>
          <Route path="/concepts" element={<ConceptsRoute />} />
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>
  );
}

describe("ConceptsRoute", () => {
  beforeEach(() => {
    useConceptsMock.mockReset();
    useConceptsMock.mockReturnValue({
      concepts: [
        {
          id: "concept-1",
          title: "AI founder copilot",
          targetUser: "solo founders",
          problem: "Too many weak inputs produce low-quality ideas.",
          opportunity: "Curate stronger trend evidence before building.",
          evidenceSummary: "Derived from one live signal.",
          risks: "",
          confidence: "medium",
          status: "draft",
          sourceItemIds: ["github:1"],
          evidenceItems: [
            {
              id: "github:1",
              source: "github",
              externalId: "1",
              title: "owner/repo",
              summary: "A useful repo.",
              url: "https://github.com/owner/repo",
              author: "owner",
              publishedAt: "2026-07-09T08:00:00.000Z",
              collectedAt: "2026-07-09T09:00:00.000Z",
              engagementCount: 200,
              score: 22.1,
              keywords: ["ai"],
            },
          ],
          createdAt: "2026-07-09T09:00:00.000Z",
          updatedAt: "2026-07-09T09:00:00.000Z",
        },
      ],
      backend: "local-fallback",
      degradedReason: null,
      isLoading: false,
      isSaving: false,
      error: null,
      saveConcept: vi.fn().mockResolvedValue({
        concept: {
          id: "concept-1",
          title: "AI founder copilot",
          targetUser: "solo founders",
          problem: "Too many weak inputs produce low-quality ideas.",
          opportunity: "Curate stronger trend evidence before building.",
          evidenceSummary: "Derived from one live signal.",
          risks: "",
          confidence: "medium",
          status: "draft",
          sourceItemIds: ["github:1"],
          evidenceItems: [
            {
              id: "github:1",
              source: "github",
              externalId: "1",
              title: "owner/repo",
              summary: "A useful repo.",
              url: "https://github.com/owner/repo",
              author: "owner",
              publishedAt: "2026-07-09T08:00:00.000Z",
              collectedAt: "2026-07-09T09:00:00.000Z",
              engagementCount: 200,
              score: 22.1,
              keywords: ["ai"],
            },
          ],
          createdAt: "2026-07-09T09:00:00.000Z",
          updatedAt: "2026-07-09T09:10:00.000Z",
        },
        backend: "local-fallback",
        degradedReason: null,
      }),
    });
  });

  test("renders the concept workspace and export controls", () => {
    renderRoute();

    expect(screen.getByRole("heading", { name: "Concept workbench" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Copy Markdown" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Copy JSON" })).toBeInTheDocument();
    expect(screen.getByDisplayValue("AI founder copilot")).toBeInTheDocument();
  });

  test("updates draft fields locally", () => {
    renderRoute();

    fireEvent.change(screen.getByDisplayValue("AI founder copilot"), {
      target: { value: "AI research assistant" },
    });

    expect(screen.getByDisplayValue("AI research assistant")).toBeInTheDocument();
  });
});
