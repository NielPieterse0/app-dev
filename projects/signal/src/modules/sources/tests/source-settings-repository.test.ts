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
  };

  return {
    builder,
    client: {
      from: vi.fn(() => builder),
      rpc: vi.fn(() => {
        const next = queue.shift() ?? { data: null, error: null };
        return Promise.resolve(next);
      }),
    },
  };
}

describe("source settings repository", () => {
  test("documents the migration contract with RLS and internal MVP warnings", () => {
    const migrationPath = path.resolve(
      import.meta.dirname,
      "../../../../supabase/migrations/003_signal_live_ingestion.sql"
    );
    const migration = readFileSync(migrationPath, "utf8");

    expect(migration).toContain("create or replace function public.save_signal_settings");
    expect(migration).toContain("security definer");
    expect(migration).toContain("Internal MVP browser settings only");
    expect(migration).toContain("revoke insert, update, delete on public.source_settings");
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
        data: {
          source_rows: createSourceSettingsRows(settings).map((row) => ({
            ...row,
            updated_at: null,
          })),
          preference_rows: [{ ...createSignalPreferencesRow(settings), updated_at: null }],
        },
        error: null,
      },
    ]);
    const repository = createSupabaseSourceSettingsRepository(client as never);

    await expect(repository.save(settings)).resolves.toEqual(settings);
  });
});
