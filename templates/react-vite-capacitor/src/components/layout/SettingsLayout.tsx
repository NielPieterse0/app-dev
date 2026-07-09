import type { ReactNode } from "react";
import { NavLink } from "react-router-dom";
import "./layouts.css";

type SettingsLayoutProps = {
  items: Array<{ label: string; href: string }>;
  children: ReactNode;
};

export function SettingsLayout({ items, children }: SettingsLayoutProps) {
  return (
    <section className="settings-layout">
      <nav aria-label="Settings sections" className="settings-layout__nav">
        {items.map((item) => (
          <NavLink
            key={item.href}
            to={item.href}
            className={({ isActive }) =>
              isActive ? "settings-layout__link settings-layout__link--active" : "settings-layout__link"
            }
          >
            {item.label}
          </NavLink>
        ))}
      </nav>
      <div className="settings-layout__panel">{children}</div>
    </section>
  );
}
