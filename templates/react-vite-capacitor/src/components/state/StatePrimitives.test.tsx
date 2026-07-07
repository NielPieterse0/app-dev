import { render, screen } from "@testing-library/react";
import { EmptyState, ErrorState, LoadingState } from ".";

test("renders empty state content and action", () => {
  render(<EmptyState title="No records" description="Create the first record." action={<button type="button">Add</button>} />);

  expect(screen.getByRole("region", { name: "No records" })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Add" })).toBeInTheDocument();
});

test("renders loading state with live status", () => {
  render(<LoadingState label="Loading accounts" />);

  expect(screen.getByText("Loading accounts")).toBeInTheDocument();
});

test("renders error state as an alert", () => {
  render(<ErrorState title="Could not load" description="Try again." />);

  expect(screen.getByRole("alert")).toHaveTextContent("Could not load");
});
