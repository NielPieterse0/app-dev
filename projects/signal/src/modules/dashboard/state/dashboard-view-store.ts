import { create } from "zustand";
import type { SourceKind } from "@/modules/sources";

type DashboardViewStore = {
  selectedSignalId: string | null;
  selectedSource: SourceKind | "all";
  setSelectedSignalId: (signalId: string | null) => void;
  setSelectedSource: (source: SourceKind | "all") => void;
};

export const useDashboardViewStore = create<DashboardViewStore>((set) => ({
  selectedSignalId: null,
  selectedSource: "all",
  setSelectedSignalId: (selectedSignalId) => set({ selectedSignalId }),
  setSelectedSource: (selectedSource) => set({ selectedSource }),
}));
