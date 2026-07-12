import { useSourceItems, type SourceKind } from "@/modules/sources";

type UseRankedItemsOptions = {
  enabledSources: SourceKind[];
  includeKeywords: string[];
};

export function useRankedItems(options: UseRankedItemsOptions) {
  return useSourceItems(options);
}
