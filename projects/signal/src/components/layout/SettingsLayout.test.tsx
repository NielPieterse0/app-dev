import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { SettingsLayout } from "./SettingsLayout";

test("SettingsLayout renders navigation and active panel content", () => {
  render(
    <MemoryRouter initialEntries={["/settings"]}>
      <SettingsLayout
        items={[
          { label: "General", href: "/settings" },
          { label: "Notifications", href: "/settings/notifications" },
        ]}
      >
        <p>Current settings panel</p>
      </SettingsLayout>
    </MemoryRouter>
  );

  expect(screen.getByRole("navigation", { name: "Settings sections" })).toBeInTheDocument();
  expect(screen.getByRole("link", { name: "General" })).toHaveAttribute("aria-current", "page");
  expect(screen.getByText("Current settings panel")).toBeInTheDocument();
});
