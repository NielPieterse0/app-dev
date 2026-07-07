import { createBrowserRouter } from "react-router-dom";
import { AppShell } from "./AppShell";
import { requireAuthSession } from "../modules/auth";
import { DashboardRoute } from "../modules/dashboard/routes/DashboardRoute";
import { ProtectedSettingsExampleRoute, SettingsRoute } from "../modules/settings/routes/SettingsRoute";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [
      { index: true, element: <DashboardRoute /> },
      { path: "settings", element: <SettingsRoute /> },
      {
        path: "settings/protected",
        loader: requireAuthSession,
        element: <ProtectedSettingsExampleRoute />,
      },
    ],
  },
]);
