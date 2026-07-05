import type { ReactNode } from "react";
import "./layouts.css";

type FormLayoutProps = {
  children: ReactNode;
  actions: ReactNode;
};

export function FormLayout({ children, actions }: FormLayoutProps) {
  return (
    <form className="form-layout">
      <div className="form-layout__fields">{children}</div>
      <div className="form-layout__actions">{actions}</div>
    </form>
  );
}
