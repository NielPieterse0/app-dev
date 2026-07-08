import { createBrowserRouter } from "react-router-dom";
import { DashboardRoute } from "@/modules/dashboard";
import {
  ProtectedSettingsExampleRoute,
  SettingsGeneralRoute,
  SettingsNotificationsRoute,
  SettingsRoute,
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
        element: <SettingsRoute />,
        children: [
          { index: true, element: <SettingsGeneralRoute /> },
          { path: "notifications", element: <SettingsNotificationsRoute /> },
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
