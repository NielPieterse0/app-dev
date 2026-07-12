import { describe, expect, test, vi } from "vitest";
import { listSourceItems, refreshSourceItems } from "../services/source-repository";
import type { SourceItemRepository } from "../services/source-item-repository";

describe("source repository", () => {
  test("filters persisted items by enabled source", async () => {
    const fallbackRepository: SourceItemRepository = {
      get: vi.fn().mockResolvedValue({
        items: [
          {
            id: "github:1",
            source: "github",
            externalId: "1",
            title: "owner/repo",
            summary: "repo summary",
            url: "https://github.com/owner/repo",
            author: "owner",
            publishedAt: "2026-07-08T10:00:00.000Z",
            collectedAt: "2026-07-08T10:10:00.000Z",
            engagementCount: 200,
            score: 24.4,
            keywords: ["agents"],
          },
          {
            id: "hacker_news:1",
            source: "hacker_news",
            externalId: "1",
            title: "Ask HN",
            summary: "hn summary",
            url: "https://news.ycombinator.com/item?id=1",
            author: "hn",
            publishedAt: "2026-07-08T09:00:00.000Z",
            collectedAt: "2026-07-08T10:10:00.000Z",
            engagementCount: 100,
            score: 20,
            keywords: ["research"],
          },
        ],
        lastRefreshedAt: "2026-07-08T10:10:00.000Z",
      }),
      replaceAll: vi.fn(),
    };

    const result = await listSourceItems(
      {
        enabledSources: ["github"],
      },
      {
        fallbackRepository,
        supabaseConfigured: false,
      }
    );

    expect(result.items).toHaveLength(1);
    expect(result.items[0]?.source).toBe("github");
  });

  test("filters persisted items by keywords", async () => {
    const fallbackRepository: SourceItemRepository = {
      get: vi.fn().mockResolvedValue({
        items: [
          {
            id: "github:1",
            source: "github",
            externalId: "1",
            title: "owner/repo",
            summary: "repo summary",
            url: "https://github.com/owner/repo",
            author: "owner",
            publishedAt: "2026-07-08T10:00:00.000Z",
            collectedAt: "2026-07-08T10:10:00.000Z",
            engagementCount: 200,
            score: 24.4,
            keywords: ["agents", "research"],
          },
        ],
        lastRefreshedAt: "2026-07-08T10:10:00.000Z",
      }),
      replaceAll: vi.fn(),
    };

    const result = await listSourceItems(
      {
        enabledSources: ["github", "hacker_news"],
        includeKeywords: ["agents"],
      },
      {
        fallbackRepository,
        supabaseConfigured: false,
      }
    );

    expect(result.items).toHaveLength(1);
    expect(result.items.every((item) => item.keywords.includes("agents"))).toBe(true);
  });

  test("persists a refreshed feed through the local fallback path", async () => {
    const replaceAll = vi.fn().mockResolvedValue({
      items: [],
      lastRefreshedAt: "2026-07-08T10:10:00.000Z",
    });
    const fallbackRepository: SourceItemRepository = {
      get: vi.fn(),
      replaceAll,
    };

    const result = await refreshSourceItems(["github"], {
      adapters: {
        github: vi.fn().mockResolvedValue([
          {
            id: "github:1",
            source: "github",
            externalId: "1",
            title: "owner/repo",
            summary: "repo summary",
            url: "https://github.com/owner/repo",
            author: "owner",
            publishedAt: "2026-07-08T10:00:00.000Z",
            collectedAt: "2026-07-08T10:10:00.000Z",
            engagementCount: 200,
            score: 24.4,
            keywords: ["agents"],
          },
        ]),
      },
      fallbackRepository,
      supabaseConfigured: false,
    });

    expect(result.backend).toBe("local-fallback");
    expect(replaceAll).toHaveBeenCalledOnce();
  });
});
