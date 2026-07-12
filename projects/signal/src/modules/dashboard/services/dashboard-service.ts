import { buildActivityPoints, type NormalizedSourceItem } from "@/modules/sources";

export function buildTrendSummary(items: NormalizedSourceItem[]) {
  const averageScore = items.length
    ? Number((items.reduce((total, item) => total + item.score, 0) / items.length).toFixed(1))
    : 0;
  const sourceCounts = items.reduce<Record<string, number>>((counts, item) => {
    counts[item.source] = (counts[item.source] ?? 0) + 1;
    return counts;
  }, {});
  const hottestSource = Object.entries(sourceCounts).sort((left, right) => right[1] - left[1])[0]?.[0] ?? "none";
  const keywordCount = new Set(items.flatMap((item) => item.keywords)).size;

  return {
    averageScore,
    hottestSource,
    keywordCount,
    totalItems: items.length,
  };
}

export function buildTrendActivity(items: NormalizedSourceItem[]) {
  return buildActivityPoints(items);
}
