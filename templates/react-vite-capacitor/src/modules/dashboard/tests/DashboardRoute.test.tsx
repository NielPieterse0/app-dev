import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, test, vi } from "vitest";
import { DashboardRoute } from "../routes/DashboardRoute";

const useDashboardModulesMock = vi.fn();
const useDashboardViewStoreMock = vi.fn();

vi.mock("../hooks/useDashboardModules", () => ({
  useDashboardModules: () => useDashboardModulesMock(),
}));

vi.mock("../state/dashboard-view-store", () => ({
  useDashboardViewStore: () => useDashboardViewStoreMock(),
}));

describe("DashboardRoute", () => {
  beforeEach(() => {
    useDashboardViewStoreMock.mockReturnValue({
      selectedStatus: "all",
      setSelectedStatus: vi.fn(),
    });
  });

  test("renders a loading state", () => {
    useDashboardModulesMock.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<DashboardRoute />);

    expect(screen.getByText("Loading dashboard modules")).toBeInTheDocument();
  });

  test("renders an empty state", () => {
    useDashboardModulesMock.mockReturnValue({
      data: [],
      isLoading: false,
      error: null,
    });

    render(<DashboardRoute />);

    expect(screen.getByRole("region", { name: "No modules found" })).toBeInTheDocument();
  });

  test("renders dashboard content when data exists", () => {
    useDashboardModulesMock.mockReturnValue({
      data: [
        { id: "planning", name: "Planning", status: "ready" },
        { id: "data-model", name: "Data model", status: "draft" },
      ],
      isLoading: false,
      error: null,
    });

    render(<DashboardRoute />);

    expect(screen.getByRole("heading", { name: "Workspace starter" })).toBeInTheDocument();
    expect(screen.getByRole("cell", { name: "Planning" })).toBeInTheDocument();
    expect(screen.getByText("Total modules")).toBeInTheDocument();
  });
});
