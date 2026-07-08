import { render, screen } from "@testing-library/react";
import { SourceActivityChart } from "../components/SourceActivityChart";

test("SourceActivityChart renders its reference heading", () => {
  render(
    <div style={{ width: 480, height: 240 }}>
      <SourceActivityChart activity={[{ label: "Jul 8", github: 2, hacker_news: 1 }]} />
    </div>
  );

  expect(screen.getByRole("heading", { name: "Source activity" })).toBeInTheDocument();
});
