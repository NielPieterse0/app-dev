import {
  createSignalPreferencesRow,
  createSourceSettingsRows,
  defaultSourceSettings,
  mapPersistedRowsToSourceSettings,
  type SourceSettingsRepository,
} from "./source-settings-repository";

const storageKey = "signal.source-settings";
let memorySettings = defaultSourceSettings;

function getStorage(storageOverride?: Storage) {
  if (storageOverride) {
    return storageOverride;
  }

  if (typeof window !== "undefined" && window.localStorage) {
    return window.localStorage;
  }

  return undefined;
}

export function createLocalSourceSettingsRepository(storageOverride?: Storage): SourceSettingsRepository {
  return {
    async get() {
      const storage = getStorage(storageOverride);
      const raw = storage?.getItem(storageKey);

      if (!raw) {
        return memorySettings;
      }

      const parsed = JSON.parse(raw) as {
        sourceRows?: unknown;
        preferenceRows?: unknown;
      };

      memorySettings = mapPersistedRowsToSourceSettings(
        parsed.sourceRows ?? createSourceSettingsRows(memorySettings),
        parsed.preferenceRows ?? [createSignalPreferencesRow(memorySettings)]
      );

      return memorySettings;
    },
    async save(settings) {
      const sourceRows = createSourceSettingsRows(settings);
      const preferenceRows = [createSignalPreferencesRow(settings)];

      memorySettings = mapPersistedRowsToSourceSettings(sourceRows, preferenceRows);
      const storage = getStorage(storageOverride);
      storage?.setItem(
        storageKey,
        JSON.stringify({
          sourceRows,
          preferenceRows,
        })
      );

      return memorySettings;
    },
  };
}
