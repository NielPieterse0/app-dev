import type { SupabaseClient } from "@supabase/supabase-js";
import {
  createSignalPreferencesRow,
  createSourceSettingsRows,
  mapPersistedRowsToSourceSettings,
  type SourceSettingsRepository,
} from "./source-settings-repository";

export function createSupabaseSourceSettingsRepository(
  client: SupabaseClient
): SourceSettingsRepository {
  return {
    async get() {
      const sourceResponse = await client
        .from("source_settings")
        .select("source, enabled, updated_at");

      if (sourceResponse.error) {
        throw new Error(`Failed to load source settings: ${sourceResponse.error.message}`);
      }

      const preferenceResponse = await client
        .from("signal_preferences")
        .select("preference_key, include_keywords, updated_at");

      if (preferenceResponse.error) {
        throw new Error(
          `Failed to load signal preferences: ${preferenceResponse.error.message}`
        );
      }

      return mapPersistedRowsToSourceSettings(
        sourceResponse.data ?? [],
        (preferenceResponse.data ?? []).filter((row) => row.preference_key === "default")
      );
    },
    async save(settings) {
      const sourceRows = createSourceSettingsRows(settings);
      const sourceResponse = await client
        .from("source_settings")
        .upsert(sourceRows, { onConflict: "source" })
        .select("source, enabled, updated_at");

      if (sourceResponse.error) {
        throw new Error(`Failed to save source settings: ${sourceResponse.error.message}`);
      }

      const preferenceResponse = await client
        .from("signal_preferences")
        .upsert(createSignalPreferencesRow(settings), { onConflict: "preference_key" })
        .select("preference_key, include_keywords, updated_at");

      if (preferenceResponse.error) {
        throw new Error(
          `Failed to save signal preferences: ${preferenceResponse.error.message}`
        );
      }

      return mapPersistedRowsToSourceSettings(
        sourceResponse.data ?? [],
        preferenceResponse.data ?? []
      );
    },
  };
}
