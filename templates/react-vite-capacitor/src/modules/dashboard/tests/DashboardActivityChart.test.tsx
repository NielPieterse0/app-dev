import { render, screen } from "@testing-library/react";
import { DashboardActivityChart } from "../components/DashboardActivityChart";

test("DashboardActivityChart renders its reference heading", () => {
  render(<DashboardActivityChart />);

  expect(screen.getByRole("heading", { name: "Module activity" })).toBeInTheDocument();
});
