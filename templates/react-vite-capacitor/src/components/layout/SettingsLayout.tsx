import type { ReactNode } from "react";
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
          <a
            key={item.href}
            aria-current={item.isActive ? "page" : undefined}
            className="settings-layout__link"
            data-active={item.isActive ? "true" : "false"}
            href={item.href}
          >
            {item.label}
          </a>
        ))}
      </nav>
      <div className="settings-layout__panel">{children}</div>
    </section>
  );
}
