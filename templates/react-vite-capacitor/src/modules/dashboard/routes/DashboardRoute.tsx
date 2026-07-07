import { PageHeader } from "../../../app/PageHeader";
import { EmptyState, ErrorState, LoadingState } from "../../../components/state";
import { DashboardActivityChart } from "../components/DashboardActivityChart";
import { DashboardModulesTable } from "../components/DashboardModulesTable";
import { DashboardSummary } from "../components/DashboardSummary";
import { useDashboardModules } from "../hooks/useDashboardModules";
import { useDashboardViewStore } from "../state/dashboard-view-store";
import "./dashboard-route.css";

export function DashboardRoute() {
  const { data, error, isLoading } = useDashboardModules();
  const { selectedStatus, setSelectedStatus } = useDashboardViewStore();

  const modules =
    selectedStatus === "all"
      ? data ?? []
      : (data ?? []).filter((module) => module.status === selectedStatus);

  return (
    <div className="dashboard-route">
      <PageHeader
        title="Workspace starter"
        description="A minimal operational surface for the first product module."
      />

      <div className="dashboard-route__filters">
        <button type="button" onClick={() => setSelectedStatus("all")}>
          All
        </button>
        <button type="button" onClick={() => setSelectedStatus("ready")}>
          Ready
        </button>
        <button type="button" onClick={() => setSelectedStatus("draft")}>
          Draft
        </button>
        <button type="button" onClick={() => setSelectedStatus("blocked")}>
          Blocked
        </button>
      </div>

      {isLoading ? <LoadingState label="Loading dashboard modules" /> : null}
      {error ? <ErrorState title="Could not load dashboard modules" description={error.message} /> : null}

      {!isLoading && !error && !modules.length ? (
        <EmptyState
          title="No modules found"
          description="Create the first module when the product decision record defines the workstream."
        />
      ) : null}

      {!isLoading && !error && modules.length ? (
        <>
          <DashboardSummary modules={modules} />
          <DashboardActivityChart />
          <DashboardModulesTable modules={modules} />
        </>
      ) : null}
    </div>
  );
}
