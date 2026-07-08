import { describe, expect, test } from "vitest";
import { listSourceItems } from "../services/source-repository";

describe("source repository", () => {
  test("returns ranked items in descending score order", async () => {
    const items = await listSourceItems();

    expect(items.length).toBeGreaterThan(0);
    expect(items[0].score).toBeGreaterThanOrEqual(items[1].score);
  });

  test("filters by enabled source", async () => {
    const items = await listSourceItems({
      enabledSources: ["github"],
    });

    expect(items.every((item) => item.source === "github")).toBe(true);
  });

  test("filters by keywords", async () => {
    const items = await listSourceItems({
      enabledSources: ["github", "hacker_news"],
      includeKeywords: ["agents"],
    });

    expect(items.length).toBeGreaterThan(0);
    expect(items.every((item) => item.keywords.includes("agents"))).toBe(true);
  });
});
