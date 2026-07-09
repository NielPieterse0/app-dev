import { render, screen } from "@testing-library/react";
import { createMemoryRouter, RouterProvider } from "react-router-dom";
import { AppShell } from "./AppShell";

test("renders navigation and child route content", () => {
  const router = createMemoryRouter(
    [
      {
        path: "/",
        element: <AppShell />,
        children: [
          { index: true, element: <p>Starter content</p> },
          { path: "settings", element: <p>Settings content</p> },
        ],
      },
    ]
  );

  render(<RouterProvider router={router} />);

  expect(screen.getByRole("navigation", { name: "Primary" })).toBeInTheDocument();
  expect(screen.getByText("Starter content")).toBeInTheDocument();
  expect(screen.getByRole("link", { name: /concepts/i })).toHaveAttribute("href", "/concepts");
  expect(screen.getByRole("link", { name: /settings/i })).toHaveAttribute("href", "/settings");
});
