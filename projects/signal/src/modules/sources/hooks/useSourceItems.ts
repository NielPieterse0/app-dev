import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import type { SourceKind } from "../schemas/source-item.schema";
import { sourceItemsQueryKey } from "../services/source-item-repository";
import { listSourceItems, refreshSourceItems } from "../services/source-repository";

type UseSourceItemsOptions = {
  enabledSources: SourceKind[];
  includeKeywords: string[];
};

export function useSourceItems(options: UseSourceItemsOptions) {
  const queryClient = useQueryClient();
  const query = useQuery({
    queryKey: [...sourceItemsQueryKey, options.enabledSources, options.includeKeywords],
    queryFn: () => listSourceItems(options),
    refetchOnWindowFocus: false,
  });
  const mutation = useMutation({
    mutationFn: () => refreshSourceItems(options.enabledSources),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: sourceItemsQueryKey,
      });
    },
  });

  return {
    items: query.data?.items ?? [],
    backend: query.data?.backend ?? "local-fallback",
    degradedReason: query.data?.degradedReason ?? null,
    lastRefreshedAt: query.data?.lastRefreshedAt ?? null,
    error:
      mutation.error instanceof Error
        ? mutation.error
        : query.error instanceof Error
          ? query.error
          : null,
    isLoading: query.isLoading,
    isRefreshing: mutation.isPending,
    refreshItems: mutation.mutateAsync,
  };
}
