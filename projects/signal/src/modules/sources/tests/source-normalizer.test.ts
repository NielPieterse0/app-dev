import { describe, expect, test } from "vitest";
import { normalizeGithubRepository, normalizeHackerNewsItem } from "../services/source-normalizer";

describe("source normalizers", () => {
  test("normalizes a GitHub repository into a ranked source item", () => {
    const item = normalizeGithubRepository(
      {
        id: "repo-1",
        name: "signal",
        owner: "trend-lab",
        description: "A trend repo.",
        stars: 225,
        url: "https://github.com/trend-lab/signal",
        pushedAt: "2026-07-07T10:00:00.000Z",
        topics: ["AI", "Research", "AI"],
      },
      new Date("2026-07-08T10:00:00.000Z")
    );

    expect(item.source).toBe("github");
    expect(item.keywords).toEqual(["ai", "research"]);
    expect(item.score).toBeGreaterThan(0);
  });

  test("normalizes a Hacker News item into a ranked source item", () => {
    const item = normalizeHackerNewsItem(
      {
        id: "hn-1",
        title: "Trend discussion",
        author: "builder",
        points: 40,
        commentCount: 15,
        url: "https://news.ycombinator.com/item?id=1",
        publishedAt: "2026-07-07T10:00:00.000Z",
        tags: ["Startups", "AI"],
      },
      new Date("2026-07-08T10:00:00.000Z")
    );

    expect(item.source).toBe("hacker_news");
    expect(item.engagementCount).toBe(55);
    expect(item.keywords).toEqual(["startups", "ai"]);
  });
});
