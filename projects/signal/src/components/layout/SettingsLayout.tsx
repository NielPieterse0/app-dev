import type { ReactNode } from "react";
import { NavLink } from "react-router-dom";
import "./layouts.css";

type SettingsLayoutProps = {
  items: Array<{ label: string; href: string; isActive?: boolean }>;
  children: ReactNode;
};

export function SettingsLayout({ items, children }: SettingsLayoutProps) {
  return (
    <section className="settings-layout">
      <nav aria-label="Settings sections" className="settings-layout__nav">
        {items.map((item) => (
          <NavLink
            key={item.href}
            className="settings-layout__link"
            data-active={item.isActive ? "true" : "false"}
            to={item.href}
          >
            {item.label}
          </NavLink>
        ))}
      </nav>
      <div className="settings-layout__panel">{children}</div>
    </section>
  );
}
