import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AppShell } from "./app/AppShell";
import { DashboardRoute } from "./modules/dashboard/routes/DashboardRoute";
import "./styles.css";

const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [{ index: true, element: <DashboardRoute /> }],
  },
], {
  future: {
    v7_relativeSplatPath: true,
  },
});

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} future={{ v7_startTransition: true }} />
    </QueryClientProvider>
  </React.StrictMode>,
);
