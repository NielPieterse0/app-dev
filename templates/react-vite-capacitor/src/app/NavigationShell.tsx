import { LayoutDashboard, Settings } from "lucide-react";

const navItems = [
  { label: "Dashboard", icon: LayoutDashboard, current: true },
  { label: "Settings", icon: Settings, current: false },
];

export function NavigationShell() {
  return (
    <nav className="navigation-shell" aria-label="Primary">
      <div className="navigation-shell__brand">app-dev</div>
      <div className="navigation-shell__items">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <a
              aria-current={item.current ? "page" : undefined}
              className="navigation-shell__item"
              href="/"
              key={item.label}
              title={item.label}
            >
              <Icon aria-hidden="true" size={18} />
              <span>{item.label}</span>
            </a>
          );
        })}
      </div>
    </nav>
  );
}
