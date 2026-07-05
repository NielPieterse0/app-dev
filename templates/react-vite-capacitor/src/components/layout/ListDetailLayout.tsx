import type { ReactNode } from "react";
import "./layouts.css";

type ListDetailLayoutProps = {
  list: ReactNode;
  detail: ReactNode;
};

export function ListDetailLayout({ list, detail }: ListDetailLayoutProps) {
  return (
    <section className="list-detail-layout">
      <div className="list-detail-layout__list">{list}</div>
      <div className="list-detail-layout__detail">{detail}</div>
    </section>
  );
}
