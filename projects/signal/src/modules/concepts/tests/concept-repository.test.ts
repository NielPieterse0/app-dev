import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, test } from "vitest";
import { buildConceptExportPayload, buildConceptMarkdown } from "../services/concept-export";
import { createLocalConceptRepository } from "../services/local-concept-repository";
import { createConceptDraftFromSourceItem } from "../schemas/concept.schema";

const sourceItem = {
  id: "github:react",
  source: "github" as const,
  externalId: "react",
  title: "facebook/react",
  summary: "A strong frontend signal with reusable compiler and runtime implications.",
  url: "https://github.com/facebook/react",
  author: "facebook",
  publishedAt: "2026-07-09T08:00:00.000Z",
  collectedAt: "2026-07-09T09:00:00.000Z",
  engagementCount: 320,
  score: 22.4,
  keywords: ["react", "compiler", "frontend"],
};

class MemoryStorage implements Storage {
  #store = new Map<string, string>();

  get length() {
    return this.#store.size;
  }

  clear() {
    this.#store.clear();
  }

  getItem(key: string) {
    return this.#store.get(key) ?? null;
  }

  key(index: number) {
    return [...this.#store.keys()][index] ?? null;
  }

  removeItem(key: string) {
    this.#store.delete(key);
  }

  setItem(key: string, value: string) {
    this.#store.set(key, value);
  }
}

describe("concept repository and export helpers", () => {
  test("saves and reloads a promoted concept draft from the local fallback repository", async () => {
    const repository = createLocalConceptRepository(new MemoryStorage());
    const concept = createConceptDraftFromSourceItem(sourceItem, new Date("2026-07-09T10:00:00.000Z"));

    await repository.save(concept);
    const concepts = await repository.list();

    expect(concepts).toHaveLength(1);
    expect(concepts[0].title).toBe("facebook/react");
    expect(concepts[0].sourceItemIds).toEqual(["github:react"]);
  });

  test("builds stable markdown and json exports from a concept", () => {
    const concept = createConceptDraftFromSourceItem(sourceItem, new Date("2026-07-09T10:00:00.000Z"));
    const markdown = buildConceptMarkdown(concept);
    const payload = buildConceptExportPayload(concept);

    expect(markdown).toContain("# facebook/react");
    expect(markdown).toContain("Supporting Signals");
    expect(payload.sourceItemIds).toEqual(["github:react"]);
    expect(payload.evidenceItems[0].sourceLabel).toBe("GitHub");
  });

  test("records the concept persistence migration contract", () => {
    const migration = readFileSync(
      resolve(process.cwd(), "supabase/migrations/004_signal_concepts.sql"),
      "utf8"
    );

    expect(migration).toContain("create table if not exists public.signal_concepts");
    expect(migration).toContain("create or replace function public.upsert_signal_concept");
    expect(migration).toContain("Not public-launch safe.");
  });
});
