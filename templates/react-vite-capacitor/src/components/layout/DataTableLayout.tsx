import type { ReactNode } from "react";
import "./layouts.css";

type DataTableLayoutProps = {
  toolbar?: ReactNode;
  children: ReactNode;
};

export function DataTableLayout({ toolbar, children }: DataTableLayoutProps) {
  return (
    <section className="data-table-layout">
      {toolbar ? <div className="data-table-layout__toolbar">{toolbar}</div> : null}
      <div className="data-table-layout__body">{children}</div>
    </section>
  );
}
