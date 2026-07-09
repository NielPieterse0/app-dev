import { createBrowserRouter } from "react-router-dom";
import { DashboardRoute } from "@/modules/dashboard";
import {
  ProtectedSettingsExampleRoute,
  SettingsExampleRoute,
  SettingsGeneralExampleRoute,
  SettingsNotificationsExampleRoute,
} from "@/modules/settings";
import { requireAuthSession } from "@/modules/auth";
import { AppShell } from "./AppShell";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [
      { index: true, element: <DashboardRoute /> },
      {
        path: "settings",
        element: <SettingsExampleRoute />,
        children: [
          { index: true, element: <SettingsGeneralExampleRoute /> },
          { path: "notifications", element: <SettingsNotificationsExampleRoute /> },
          {
            path: "protected",
            loader: requireAuthSession,
            element: <ProtectedSettingsExampleRoute />,
          },
        ],
      },
    ],
  },
]);
