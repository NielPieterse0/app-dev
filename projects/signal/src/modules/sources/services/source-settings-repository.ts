import { z } from "zod";
import {
  normalizeKeywordInput,
  sourceKindSchema,
  sourceSettingsSchema,
  type SourceKind,
  type SourceSettings,
} from "../schemas/source-item.schema";

export type SettingsBackend = "supabase" | "local-fallback";

export type SourceSettingsRepository = {
  get(): Promise<SourceSettings>;
  save(settings: SourceSettings): Promise<SourceSettings>;
};

export const sourceSettingsQueryKey = ["source-settings"] as const;

export const defaultSourceSettings: SourceSettings = sourceSettingsSchema.parse({
  enabledSources: ["github", "hacker_news"],
  includeKeywords: [],
});

const sourceSettingsRowSchema = z.object({
  enabled: z.boolean(),
  source: sourceKindSchema,
  updated_at: z.string().nullable().optional(),
});

const signalPreferencesRowSchema = z.object({
  include_keywords: z.array(z.string()).default([]),
  preference_key: z.literal("default"),
  updated_at: z.string().nullable().optional(),
});

const signalSettingsRpcResultSchema = z.object({
  preference_rows: z.array(signalPreferencesRowSchema).max(1).default([]),
  source_rows: z.array(sourceSettingsRowSchema).default([]),
});

export const sourceSettingsRowsSchema = z.array(sourceSettingsRowSchema);
export const signalPreferencesRowsSchema = z.array(signalPreferencesRowSchema).max(1);

const sourceKinds = sourceKindSchema.options as SourceKind[];

export function mapPersistedRowsToSourceSettings(
  sourceRows: unknown,
  preferenceRows: unknown
): SourceSettings {
  const parsedSourceRows = sourceSettingsRowsSchema.parse(sourceRows);
  const parsedPreferenceRows = signalPreferencesRowsSchema.parse(preferenceRows);
  const enabledSourceSet = new Set(
    parsedSourceRows.filter((row) => row.enabled).map((row) => row.source)
  );

  const enabledSources = sourceKinds.filter((source) =>
    parsedSourceRows.length
      ? enabledSourceSet.has(source)
      : defaultSourceSettings.enabledSources.includes(source)
  );
  const preferenceRow = parsedPreferenceRows[0];

  return sourceSettingsSchema.parse({
    enabledSources: enabledSources.length ? enabledSources : defaultSourceSettings.enabledSources,
    includeKeywords: normalizeKeywordInput((preferenceRow?.include_keywords ?? []).join(",")),
  });
}

export function createSourceSettingsRows(settings: SourceSettings) {
  const parsedSettings = sourceSettingsSchema.parse(settings);

  return sourceKinds.map((source) => ({
    source,
    enabled: parsedSettings.enabledSources.includes(source),
  }));
}

export function createSignalPreferencesRow(settings: SourceSettings) {
  const parsedSettings = sourceSettingsSchema.parse(settings);

  return {
    preference_key: "default" as const,
    include_keywords: parsedSettings.includeKeywords,
  };
}

export function mapSignalSettingsRpcPayload(payload: unknown) {
  const parsedPayload = signalSettingsRpcResultSchema.parse(payload);

  return mapPersistedRowsToSourceSettings(
    parsedPayload.source_rows,
    parsedPayload.preference_rows
  );
}
