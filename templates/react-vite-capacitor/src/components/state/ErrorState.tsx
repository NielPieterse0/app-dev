import type { ReactNode } from "react";
import "./state.css";

type ErrorStateProps = {
  title: string;
  description: string;
  action?: ReactNode;
};

export function ErrorState({ action, description, title }: ErrorStateProps) {
  return (
    <section className="state-block state-block--error" role="alert">
      <h2>{title}</h2>
      <p>{description}</p>
      {action ? <div className="state-block__action">{action}</div> : null}
    </section>
  );
}
