import { describe, expect, test, vi } from "vitest";
import { fetchGithubSourceItems } from "../services/github-source-adapter";

describe("github source adapter", () => {
  test("normalizes GitHub search results", async () => {
    const fetcher = vi.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({
        items: [
          {
            id: 42,
            name: "agent-runtime",
            full_name: "open-operators/agent-runtime",
            owner: { login: "open-operators" },
            description: "Runtime patterns for agent workflows.",
            html_url: "https://github.com/open-operators/agent-runtime",
            stargazers_count: 120,
            pushed_at: "2026-07-08T10:00:00.000Z",
            topics: ["agents", "automation"],
            language: "TypeScript",
          },
        ],
      }),
    });

    const items = await fetchGithubSourceItems(fetcher as never, new Date("2026-07-08T12:00:00.000Z"));

    expect(items).toHaveLength(1);
    expect(items[0]?.source).toBe("github");
    expect(items[0]?.keywords).toContain("agents");
  });
});
