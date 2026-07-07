import { z } from "zod";

export const dashboardModuleSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  status: z.enum(["ready", "draft", "blocked"]),
});

export const dashboardModulesSchema = z.array(dashboardModuleSchema);

export type DashboardModule = z.infer<typeof dashboardModuleSchema>;
