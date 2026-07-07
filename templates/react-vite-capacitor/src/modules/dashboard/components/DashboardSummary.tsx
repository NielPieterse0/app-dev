import type { DashboardModule } from "../schemas/dashboard-module.schema";

type DashboardSummaryProps = {
  modules: DashboardModule[];
};

export function DashboardSummary({ modules }: DashboardSummaryProps) {
  const readyCount = modules.filter((module) => module.status === "ready").length;
  const draftCount = modules.filter((module) => module.status === "draft").length;
  const blockedCount = modules.filter((module) => module.status === "blocked").length;

  return (
    <dl className="dashboard-route__summary">
      <div>
        <dt>Total modules</dt>
        <dd>{modules.length}</dd>
      </div>
      <div>
        <dt>Ready</dt>
        <dd>{readyCount}</dd>
      </div>
      <div>
        <dt>Draft</dt>
        <dd>{draftCount}</dd>
      </div>
      <div>
        <dt>Blocked</dt>
        <dd>{blockedCount}</dd>
      </div>
    </dl>
  );
}
