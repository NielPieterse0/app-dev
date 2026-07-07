import { CartesianGrid, Line, LineChart, XAxis } from "recharts";
import { ChartContainer, ChartTooltip, ChartTooltipContent, type ChartConfig } from "../../../components/ui/chart";

const chartData = [
  { week: "W1", activity: 2 },
  { week: "W2", activity: 4 },
  { week: "W3", activity: 3 },
  { week: "W4", activity: 5 },
];

const chartConfig = {
  activity: {
    label: "Module activity",
    color: "var(--color-chart-1)",
  },
} satisfies ChartConfig;

export function DashboardActivityChart() {
  return (
    <section aria-labelledby="dashboard-activity-chart-title" className="dashboard-route__chart">
      <h2 id="dashboard-activity-chart-title">Module activity</h2>
      <ChartContainer className="h-[220px] w-full" config={chartConfig}>
        <LineChart accessibilityLayer data={chartData}>
          <CartesianGrid vertical={false} />
          <XAxis axisLine={false} dataKey="week" tickLine={false} tickMargin={8} />
          <ChartTooltip content={<ChartTooltipContent />} cursor={false} />
          <Line dataKey="activity" dot={false} stroke="var(--color-activity)" strokeWidth={2} type="monotone" />
        </LineChart>
      </ChartContainer>
    </section>
  );
}
