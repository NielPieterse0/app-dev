import "./state.css";

type LoadingStateProps = {
  label?: string;
};

export function LoadingState({ label = "Loading" }: LoadingStateProps) {
  return (
    <section className="state-block" aria-busy="true" aria-live="polite">
      <div className="state-block__spinner" aria-hidden="true" />
      <p>{label}</p>
    </section>
  );
}
