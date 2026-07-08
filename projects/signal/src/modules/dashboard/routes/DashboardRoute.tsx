import { PageHeader } from "../../../app/PageHeader";
import { EmptyState, ErrorState, LoadingState } from "../../../components/state";
import { getEnabledKeywordFilters, useSourcePreferencesStore } from "@/modules/sources";
import { RankedItemsTable } from "../components/RankedItemsTable";
import { SourceActivityChart } from "../components/SourceActivityChart";
import { TrendSummaryCards } from "../components/TrendSummaryCards";
import { useRankedItems } from "../hooks/useRankedItems";
import { buildTrendActivity, buildTrendSummary } from "../services/dashboard-service";
import { useDashboardViewStore } from "../state/dashboard-view-store";
import "./dashboard-route.css";

export function DashboardRoute() {
  const enabledSources = useSourcePreferencesStore((state) => state.enabledSources);
  const includeKeywordsText = useSourcePreferencesStore((state) => state.includeKeywordsText);
  const { data, error, isLoading } = useRankedItems({
    enabledSources,
    includeKeywords: getEnabledKeywordFilters(includeKeywordsText),
  });
  const { selectedSource, setSelectedSource } = useDashboardViewStore();

  const items =
    selectedSource === "all"
      ? data ?? []
      : (data ?? []).filter((item) => item.source === selectedSource);
  const summary = buildTrendSummary(items);
  const activity = buildTrendActivity(items);

  return (
    <div className="dashboard-route">
      <PageHeader
        title="Trend scout"
        description="Rank public GitHub and Hacker News signals before they become app concepts."
      />

      <div className="dashboard-route__filters">
        <button type="button" onClick={() => setSelectedSource("all")}>
          All
        </button>
        <button type="button" onClick={() => setSelectedSource("github")}>
          GitHub
        </button>
        <button type="button" onClick={() => setSelectedSource("hacker_news")}>
          Hacker News
        </button>
      </div>

      {getEnabledKeywordFilters(includeKeywordsText).length ? (
        <p className="dashboard-route__hint">
          Keyword filter: {getEnabledKeywordFilters(includeKeywordsText).join(", ")}
        </p>
      ) : null}

      {isLoading ? <LoadingState label="Loading source signals" /> : null}
      {error ? <ErrorState title="Could not load source signals" description={error.message} /> : null}

      {!isLoading && !error && !items.length ? (
        <EmptyState
          title="No signals match the current view"
          description="Enable more sources or relax the keyword filter in Settings to widen the scouting net."
        />
      ) : null}

      {!isLoading && !error && items.length ? (
        <>
          <TrendSummaryCards
            averageScore={summary.averageScore}
            hottestSource={summary.hottestSource}
            keywordCount={summary.keywordCount}
            totalItems={summary.totalItems}
          />
          <SourceActivityChart activity={activity} />
          <RankedItemsTable items={items} />
        </>
      ) : null}
    </div>
  );
}
