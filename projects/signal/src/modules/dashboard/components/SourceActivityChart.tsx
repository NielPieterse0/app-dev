import { CartesianGrid, Line, LineChart, XAxis } from "recharts";
import {
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from "../../../components/ui/chart";

type SourceActivityChartProps = {
  activity: Array<{ label: string; github: number; hacker_news: number }>;
};

const chartConfig = {
  github: {
    label: "GitHub",
    color: "var(--color-chart-1)",
  },
  hacker_news: {
    label: "Hacker News",
    color: "var(--color-chart-2)",
  },
} satisfies ChartConfig;

export function SourceActivityChart({ activity }: SourceActivityChartProps) {
  return (
    <section aria-labelledby="dashboard-activity-chart-title" className="dashboard-route__chart">
      <h2 id="dashboard-activity-chart-title">Source activity</h2>
      <ChartContainer className="h-[220px] w-full" config={chartConfig}>
        <LineChart accessibilityLayer data={activity}>
          <CartesianGrid vertical={false} />
          <XAxis axisLine={false} dataKey="label" tickLine={false} tickMargin={8} />
          <ChartLegend content={<ChartLegendContent />} />
          <ChartTooltip content={<ChartTooltipContent />} cursor={false} />
          <Line dataKey="github" dot={false} stroke="var(--color-github)" strokeWidth={2} type="monotone" />
          <Line
            dataKey="hacker_news"
            dot={false}
            stroke="var(--color-hacker_news)"
            strokeWidth={2}
            type="monotone"
          />
        </LineChart>
      </ChartContainer>
    </section>
  );
}
