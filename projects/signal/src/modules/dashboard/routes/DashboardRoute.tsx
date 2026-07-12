import { useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { PageHeader } from "../../../app/PageHeader";
import { Button } from "../../../components/ui/button";
import { EmptyState, ErrorState, LoadingState } from "../../../components/state";
import { getEnabledKeywordFilters, useSourcePreferencesStore } from "@/modules/sources";
import {
  createConceptDraftFromSourceItem,
  SignalDetailCard,
  useSaveConcept,
} from "@/modules/concepts";
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
  const { saveConcept, isSaving: isPromotingConcept } = useSaveConcept();
  const navigate = useNavigate();
  const { selectedSignalId, selectedSource, setSelectedSignalId, setSelectedSource } =
    useDashboardViewStore();

  const items = useMemo(
    () =>
      selectedSource === "all"
        ? data ?? []
        : (data ?? []).filter((item) => item.source === selectedSource),
    [data, selectedSource]
  );
  const selectedSignal = items.find((item) => item.id === selectedSignalId) ?? null;
  const summary = buildTrendSummary(items);
  const activity = buildTrendActivity(items);

  useEffect(() => {
    if (selectedSignalId && !items.some((item) => item.id === selectedSignalId)) {
      setSelectedSignalId(null);
    }
  }, [items, selectedSignalId, setSelectedSignalId]);

  async function handlePromoteSignal() {
    if (!selectedSignal) {
      return;
    }

    const conceptDraft = createConceptDraftFromSourceItem(selectedSignal);
    const savedConcept = await saveConcept(conceptDraft);
    navigate(`/concepts?concept=${savedConcept.concept.id}`);
  }

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
              ? "configured remote persisted source feed"
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
        <Button aria-pressed={selectedSource === "all"} type="button" variant={selectedSource === "all" ? "default" : "outline"} onClick={() => setSelectedSource("all")}>
          All
        </Button>
        <Button aria-pressed={selectedSource === "github"} type="button" variant={selectedSource === "github" ? "default" : "outline"} onClick={() => setSelectedSource("github")}>
          GitHub
        </Button>
        <Button aria-pressed={selectedSource === "hacker_news"} type="button" variant={selectedSource === "hacker_news" ? "default" : "outline"} onClick={() => setSelectedSource("hacker_news")}>
          Hacker News
        </Button>
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
          <SignalDetailCard
            isPromoting={isPromotingConcept}
            item={selectedSignal}
            onPromote={() => void handlePromoteSignal()}
          />
          <RankedItemsTable
            backend={backend}
            items={items}
            onInspect={(item) => setSelectedSignalId(item.id)}
            selectedSignalId={selectedSignalId}
          />
        </>
      ) : null}
    </div>
  );
}
