export const homeCopy = {
  title: "Next app ready",
  description: "Replace this starter page with the first product workflow.",
};

export default function HomePage() {
  return (
    <main className="page-shell">
      <section className="page-panel">
        <p className="page-kicker">app-dev</p>
        <h1>{homeCopy.title}</h1>
        <p>{homeCopy.description}</p>
      </section>
    </main>
  );
}
