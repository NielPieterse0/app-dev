import { create } from "zustand";
import type { SourceKind } from "@/modules/sources";

type DashboardViewStore = {
  selectedSource: SourceKind | "all";
  setSelectedSource: (source: SourceKind | "all") => void;
};

export const useDashboardViewStore = create<DashboardViewStore>((set) => ({
  selectedSource: "all",
  setSelectedSource: (selectedSource) => set({ selectedSource }),
}));
