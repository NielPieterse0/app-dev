import { render, screen } from "@testing-library/react";
import { SettingsLayout } from "./SettingsLayout";

test("SettingsLayout renders navigation and active panel content", () => {
  render(
    <SettingsLayout
      items={[
        { label: "General", href: "/settings", isActive: true },
        { label: "Notifications", href: "/settings/notifications" },
      ]}
    >
      <p>Current settings panel</p>
    </SettingsLayout>
  );

  expect(screen.getByRole("navigation", { name: "Settings sections" })).toBeInTheDocument();
  expect(screen.getByRole("link", { name: "General" })).toHaveAttribute("aria-current", "page");
  expect(screen.getByText("Current settings panel")).toBeInTheDocument();
});
