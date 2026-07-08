import { Outlet } from "react-router-dom";
import { NavigationShell } from "./NavigationShell";
import "./app-shell.css";

export function AppShell() {
  return (
    <div className="app-shell">
      <NavigationShell />
      <main className="app-shell__main">
        <Outlet />
      </main>
    </div>
  );
}
