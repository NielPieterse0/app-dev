import { dashboardModulesSchema, type DashboardModule } from "../schemas/dashboard-module.schema";

const seededModules: DashboardModule[] = [
  { id: "planning", name: "Planning", status: "ready" },
  { id: "data-model", name: "Data model", status: "draft" },
  { id: "verification", name: "Verification", status: "ready" },
];

export async function getDashboardModules(): Promise<DashboardModule[]> {
  return dashboardModulesSchema.parse(seededModules);
}
