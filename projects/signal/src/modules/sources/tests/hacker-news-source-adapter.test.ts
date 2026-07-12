import { describe, expect, test, vi } from "vitest";
import { fetchHackerNewsSourceItems } from "../services/hacker-news-source-adapter";

describe("hacker news source adapter", () => {
  test("normalizes top-story responses", async () => {
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => [1001],
      })
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          id: 1001,
          by: "builder",
          descendants: 24,
          score: 90,
          time: 1751968800,
          title: "Context engineering for focused agent workflows",
          type: "story",
          url: "https://example.com/context-engineering",
        }),
      });

    const items = await fetchHackerNewsSourceItems(
      fetcher as never,
      new Date("2026-07-08T12:00:00.000Z")
    );

    expect(items).toHaveLength(1);
    expect(items[0]?.source).toBe("hacker_news");
    expect(items[0]?.keywords).toContain("context");
  });
});
