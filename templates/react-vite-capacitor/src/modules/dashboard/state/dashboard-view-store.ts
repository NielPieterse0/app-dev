import { create } from "zustand";
import type { DashboardModule } from "../schemas/dashboard-module.schema";

type DashboardViewStore = {
  selectedStatus: DashboardModule["status"] | "all";
  setSelectedStatus: (status: DashboardModule["status"] | "all") => void;
};

export const useDashboardViewStore = create<DashboardViewStore>((set) => ({
  selectedStatus: "all",
  setSelectedStatus: (selectedStatus) => set({ selectedStatus }),
}));
