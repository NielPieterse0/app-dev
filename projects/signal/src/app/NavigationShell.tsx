import { LayoutDashboard, Lightbulb, Settings } from "lucide-react";
import { NavLink } from "react-router-dom";

const navItems = [
  { label: "Feed", icon: LayoutDashboard, to: "/" },
  { label: "Concepts", icon: Lightbulb, to: "/concepts" },
  { label: "Settings", icon: Settings, to: "/settings" },
];

export function NavigationShell() {
  return (
    <nav className="navigation-shell" aria-label="Primary">
      <div className="navigation-shell__brand">Signal</div>
      <div className="navigation-shell__items">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              className={({ isActive }) =>
                isActive ? "navigation-shell__item navigation-shell__item--active" : "navigation-shell__item"
              }
              end={item.to === "/"}
              key={item.label}
              title={item.label}
              to={item.to}
            >
              <Icon aria-hidden="true" size={18} />
              <span>{item.label}</span>
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
}
