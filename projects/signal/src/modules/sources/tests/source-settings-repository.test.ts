import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, test, vi } from "vitest";
import { createLocalSourceSettingsRepository } from "../services/local-source-settings-repository";
import {
  createSignalPreferencesRow,
  createSourceSettingsRows,
  defaultSourceSettings,
  mapPersistedRowsToSourceSettings,
} from "../services/source-settings-repository";
import { createSupabaseSourceSettingsRepository } from "../services/supabase-source-settings-repository";
import type { SourceSettings } from "../schemas/source-item.schema";

function createSupabaseTableMock(responses: Array<{ data: unknown; error: { message: string } | null }>) {
  const queue = [...responses];

  const builder = {
    select: vi.fn(() => {
      const next = queue.shift() ?? { data: [], error: null };
      return Promise.resolve(next);
    }),
    eq: vi.fn(() => builder),
    upsert: vi.fn(() => builder),
  };

  return {
    builder,
    client: {
      from: vi.fn(() => builder),
    },
  };
}

describe("source settings repository", () => {
  test("documents the migration contract with RLS and internal MVP warnings", () => {
    const migrationPath = path.resolve(
      import.meta.dirname,
      "../../../../supabase/migrations/002_live_source_settings.sql"
    );
    const migration = readFileSync(migrationPath, "utf8");

    expect(migration).toContain("create table if not exists public.signal_preferences");
    expect(migration).toContain("alter table public.source_settings enable row level security");
    expect(migration).toContain("alter table public.signal_preferences enable row level security");
    expect(migration).toContain("Internal MVP browser settings only");
    expect(migration).toContain("grant select, insert, update on public.source_settings to anon, authenticated");
    expect(migration).not.toContain("service_role");
  });

  test("maps persisted rows into normalized settings", () => {
    const settings = mapPersistedRowsToSourceSettings(
      [
        { source: "github", enabled: true, updated_at: null },
        { source: "hacker_news", enabled: false, updated_at: null },
      ],
      [{ preference_key: "default", include_keywords: ["Agents", "research"], updated_at: null }]
    );

    expect(settings).toEqual({
      enabledSources: ["github"],
      includeKeywords: ["agents", "research"],
    });
  });

  test("rejects malformed persisted rows", () => {
    expect(() =>
      mapPersistedRowsToSourceSettings(
        [{ source: "rss", enabled: true, updated_at: null }],
        [{ preference_key: "default", include_keywords: [], updated_at: null }]
      )
    ).toThrow();
  });

  test("uses deterministic local fallback defaults and saves locally", async () => {
    const storage = {
      getItem: vi.fn(() => null),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
      key: vi.fn(),
      length: 0,
    } as unknown as Storage;
    const repository = createLocalSourceSettingsRepository(storage);

    await expect(repository.get()).resolves.toEqual(defaultSourceSettings);

    await expect(
      repository.save({
        enabledSources: ["github"],
        includeKeywords: ["agents"],
      })
    ).resolves.toEqual({
      enabledSources: ["github"],
      includeKeywords: ["agents"],
    });

    expect(storage.setItem).toHaveBeenCalledOnce();
  });

  test("reads configured settings from Supabase", async () => {
    const { client } = createSupabaseTableMock([
      {
        data: createSourceSettingsRows({
          enabledSources: ["github"],
          includeKeywords: ["agents"],
        }).map((row) => ({ ...row, updated_at: null })),
        error: null,
      },
      {
        data: [{ ...createSignalPreferencesRow({ enabledSources: ["github"], includeKeywords: ["agents"] }), updated_at: null }],
        error: null,
      },
    ]);
    const repository = createSupabaseSourceSettingsRepository(client as never);

    await expect(repository.get()).resolves.toEqual({
      enabledSources: ["github"],
      includeKeywords: ["agents"],
    });
  });

  test("surfaces Supabase request failures", async () => {
    const { client } = createSupabaseTableMock([
      {
        data: null,
        error: { message: "database unavailable" },
      },
    ]);
    const repository = createSupabaseSourceSettingsRepository(client as never);

    await expect(repository.get()).rejects.toThrow("database unavailable");
  });

  test("saves configured settings through Supabase and validates the response", async () => {
    const settings: SourceSettings = {
      enabledSources: ["github"],
      includeKeywords: ["agents", "research"],
    };
    const { client } = createSupabaseTableMock([
      {
        data: createSourceSettingsRows(settings).map((row) => ({ ...row, updated_at: null })),
        error: null,
      },
      {
        data: [{ ...createSignalPreferencesRow(settings), updated_at: null }],
        error: null,
      },
    ]);
    const repository = createSupabaseSourceSettingsRepository(client as never);

    await expect(repository.save(settings)).resolves.toEqual(settings);
  });
});
