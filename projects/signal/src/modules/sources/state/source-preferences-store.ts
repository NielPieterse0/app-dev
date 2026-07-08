import { create } from "zustand";
import { normalizeKeywordInput, type SourceKind } from "../schemas/source-item.schema";
import type { SourceSettings } from "../schemas/source-item.schema";
import { defaultSourceSettings } from "../services/source-settings-repository";

type SourcePreferencesStore = {
  enabledSources: SourceKind[];
  hasHydrated: boolean;
  includeKeywordsText: string;
  isDirty: boolean;
  hydrateFromSettings: (settings: SourceSettings, options?: { force?: boolean }) => void;
  setSourceEnabled: (source: SourceKind, enabled: boolean) => void;
  setIncludeKeywordsText: (value: string) => void;
};

export const useSourcePreferencesStore = create<SourcePreferencesStore>((set) => ({
  enabledSources: defaultSourceSettings.enabledSources,
  hasHydrated: false,
  includeKeywordsText: "",
  isDirty: false,
  hydrateFromSettings: (settings, options) =>
    set((state) => {
      if (state.isDirty && !options?.force) {
        return state;
      }

      return {
        enabledSources: settings.enabledSources,
        hasHydrated: true,
        includeKeywordsText: settings.includeKeywords.join(", "),
        isDirty: false,
      };
    }),
  setSourceEnabled: (source, enabled) =>
    set((state) => {
      const nextEnabledSources = enabled
        ? [...new Set([...state.enabledSources, source])]
        : state.enabledSources.filter((entry) => entry !== source);
      const normalizedEnabledSources = nextEnabledSources.length ? nextEnabledSources : [source];
      const didChange =
        normalizedEnabledSources.length !== state.enabledSources.length ||
        normalizedEnabledSources.some((entry, index) => entry !== state.enabledSources[index]);

      return {
        enabledSources: normalizedEnabledSources,
        isDirty: didChange ? true : state.isDirty,
      };
    }),
  setIncludeKeywordsText: (includeKeywordsText) =>
    set((state) => ({
      includeKeywordsText,
      isDirty: includeKeywordsText !== state.includeKeywordsText ? true : state.isDirty,
    })),
}));

export function getEnabledKeywordFilters(includeKeywordsText: string) {
  return normalizeKeywordInput(includeKeywordsText);
}
