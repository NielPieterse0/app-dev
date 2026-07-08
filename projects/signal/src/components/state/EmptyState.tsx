import type { ReactNode } from "react";
import "./state.css";

type EmptyStateProps = {
  title: string;
  description?: string;
  action?: ReactNode;
};

export function EmptyState({ action, description, title }: EmptyStateProps) {
  return (
    <section className="state-block" aria-label={title}>
      <h2>{title}</h2>
      {description ? <p>{description}</p> : null}
      {action ? <div className="state-block__action">{action}</div> : null}
    </section>
  );
}
