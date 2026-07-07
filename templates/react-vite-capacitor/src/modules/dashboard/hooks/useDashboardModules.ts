import { useQuery } from "@tanstack/react-query";
import { getDashboardModules } from "../services/dashboard-service";

export function useDashboardModules() {
  return useQuery({
    queryKey: ["dashboard", "modules"],
    queryFn: getDashboardModules,
  });
}
