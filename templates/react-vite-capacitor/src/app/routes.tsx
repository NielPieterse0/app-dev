import { createBrowserRouter } from "react-router-dom";
import { AppShell } from "./AppShell";
import { DashboardRoute } from "../modules/dashboard/routes/DashboardRoute";
import { SettingsRoute } from "../modules/settings/routes/SettingsRoute";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [
      { index: true, element: <DashboardRoute /> },
      { path: "settings", element: <SettingsRoute /> },
    ],
  },
]);
