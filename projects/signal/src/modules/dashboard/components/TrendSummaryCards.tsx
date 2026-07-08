import { Card, CardContent, CardHeader, CardTitle } from "../../../components/ui/card";

type TrendSummaryCardsProps = {
  averageScore: number;
  hottestSource: string;
  keywordCount: number;
  totalItems: number;
};

export function TrendSummaryCards({
  averageScore,
  hottestSource,
  keywordCount,
  totalItems,
}: TrendSummaryCardsProps) {
  return (
    <section className="dashboard-route__summary" aria-label="Signal summary">
      <Card>
        <CardHeader className="pb-3">
          <CardTitle>Total signals</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="dashboard-route__summary-value">{totalItems}</p>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="pb-3">
          <CardTitle>Average score</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="dashboard-route__summary-value">{averageScore}</p>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="pb-3">
          <CardTitle>Hottest source</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="dashboard-route__summary-value dashboard-route__summary-value--label">
            {hottestSource.replace("_", " ")}
          </p>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="pb-3">
          <CardTitle>Tracked keywords</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="dashboard-route__summary-value">{keywordCount}</p>
        </CardContent>
      </Card>
    </section>
  );
}
