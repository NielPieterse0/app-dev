import { PageHeader } from "../../../app/PageHeader";
import { Button } from "../../../components/ui/button";
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
  const {
    backend,
    degradedReason,
    error,
    isLoading,
    isRefreshing,
    items: data,
    lastRefreshedAt,
    refreshItems,
  } = useRankedItems({
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

      <div className="dashboard-route__toolbar">
        <div className="dashboard-route__toolbar-copy">
          <p className="dashboard-route__meta">
            Feed backend:{" "}
            {backend === "supabase"
              ? "Supabase persisted source feed"
              : "local fallback persisted source feed"}
          </p>
          <p className="dashboard-route__meta">
            {lastRefreshedAt
              ? `Last refresh: ${new Date(lastRefreshedAt).toLocaleString()}`
              : "No persisted feed yet. Run a manual refresh to ingest live signals."}
          </p>
          {degradedReason ? (
            <p className="dashboard-route__meta">Degraded mode reason: {degradedReason}</p>
          ) : null}
        </div>
        <Button disabled={isRefreshing} onClick={() => void refreshItems()} type="button">
          {isRefreshing ? "Refreshing live feed..." : "Refresh live feed"}
        </Button>
      </div>

      <div className="dashboard-route__filters">
        <button
          aria-pressed={selectedSource === "all"}
          type="button"
          onClick={() => setSelectedSource("all")}
        >
          All
        </button>
        <button
          aria-pressed={selectedSource === "github"}
          type="button"
          onClick={() => setSelectedSource("github")}
        >
          GitHub
        </button>
        <button
          aria-pressed={selectedSource === "hacker_news"}
          type="button"
          onClick={() => setSelectedSource("hacker_news")}
        >
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
          title={
            lastRefreshedAt
              ? "No signals match the current view"
              : "No persisted signals yet"
          }
          description={
            lastRefreshedAt
              ? "Enable more sources or relax the keyword filter in Settings to widen the scouting net."
              : "Run a manual refresh to ingest live GitHub and Hacker News signals into the persisted feed."
          }
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
          <RankedItemsTable backend={backend} items={items} />
        </>
      ) : null}
    </div>
  );
}
