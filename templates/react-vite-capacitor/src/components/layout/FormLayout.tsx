import type { FormEventHandler, ReactNode } from "react";
import "./layouts.css";

type FormLayoutProps = {
  children: ReactNode;
  actions: ReactNode;
  isPending?: boolean;
  onSubmit: FormEventHandler<HTMLFormElement>;
};

export function FormLayout({ actions, children, isPending = false, onSubmit }: FormLayoutProps) {
  return (
    <form aria-busy={isPending} className="form-layout" onSubmit={onSubmit}>
      <fieldset className="form-layout__fields" disabled={isPending}>
        {children}
      </fieldset>
      <div className="form-layout__actions">{actions}</div>
    </form>
  );
}
