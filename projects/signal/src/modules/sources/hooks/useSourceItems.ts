import { useQuery } from "@tanstack/react-query";
import type { SourceKind } from "../schemas/source-item.schema";
import { listSourceItems } from "../services/source-repository";

type UseSourceItemsOptions = {
  enabledSources: SourceKind[];
  includeKeywords: string[];
};

export function useSourceItems(options: UseSourceItemsOptions) {
  return useQuery({
    queryKey: ["sources", "items", options.enabledSources, options.includeKeywords],
    queryFn: () => listSourceItems(options),
  });
}
