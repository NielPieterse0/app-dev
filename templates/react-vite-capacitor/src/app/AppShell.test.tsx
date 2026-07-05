import { render, screen } from "@testing-library/react";
import { createMemoryRouter, RouterProvider } from "react-router-dom";
import { AppShell } from "./AppShell";

test("renders navigation and child route content", () => {
  const router = createMemoryRouter(
    [
      {
        path: "/",
        element: <AppShell />,
        children: [{ index: true, element: <p>Starter content</p> }],
      },
    ],
    {
      future: {
        v7_relativeSplatPath: true,
      },
    },
  );

  render(<RouterProvider router={router} future={{ v7_startTransition: true }} />);

  expect(screen.getByRole("navigation", { name: "Primary" })).toBeInTheDocument();
  expect(screen.getByText("Starter content")).toBeInTheDocument();
});
