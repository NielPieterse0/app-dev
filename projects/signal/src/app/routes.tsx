import { createBrowserRouter } from "react-router-dom";
import { ConceptsRoute } from "@/modules/concepts";
import { DashboardRoute } from "@/modules/dashboard";
import { SettingsKeywordsRoute, SettingsRoute, SettingsSourcesRoute } from "@/modules/settings";
import { AppShell } from "./AppShell";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [
      { index: true, element: <DashboardRoute /> },
      { path: "concepts", element: <ConceptsRoute /> },
      {
        path: "settings",
        element: <SettingsRoute />,
        children: [
          { index: true, element: <SettingsSourcesRoute /> },
          { path: "keywords", element: <SettingsKeywordsRoute /> },
        ],
      },
    ],
  },
]);
