import { create } from "zustand";
import { normalizeKeywordInput, type SourceKind } from "../schemas/source-item.schema";
import { defaultSourceSettings } from "../services/source-repository";

type SourcePreferencesStore = {
  enabledSources: SourceKind[];
  includeKeywordsText: string;
  setSourceEnabled: (source: SourceKind, enabled: boolean) => void;
  setIncludeKeywordsText: (value: string) => void;
};

export const useSourcePreferencesStore = create<SourcePreferencesStore>((set) => ({
  enabledSources: defaultSourceSettings.enabledSources,
  includeKeywordsText: "",
  setSourceEnabled: (source, enabled) =>
    set((state) => {
      const nextEnabledSources = enabled
        ? [...new Set([...state.enabledSources, source])]
        : state.enabledSources.filter((entry) => entry !== source);

      return {
        enabledSources: nextEnabledSources.length ? nextEnabledSources : [source],
      };
    }),
  setIncludeKeywordsText: (includeKeywordsText) => set({ includeKeywordsText }),
}));

export function getEnabledKeywordFilters(includeKeywordsText: string) {
  return normalizeKeywordInput(includeKeywordsText);
}
