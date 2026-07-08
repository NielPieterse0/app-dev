import type { ColumnDef } from "@tanstack/react-table";
import { Badge } from "../../../components/ui/badge";
import { DataTableLayout } from "../../../components/layout/DataTableLayout";
import type { NormalizedSourceItem } from "@/modules/sources";

type RankedItemsTableProps = {
  items: NormalizedSourceItem[];
};

const columns: ColumnDef<NormalizedSourceItem>[] = [
  {
    accessorKey: "title",
    header: "Signal",
    cell: ({ row }) => (
      <div className="dashboard-route__signal-cell">
        <a className="dashboard-route__signal-link" href={row.original.url} rel="noreferrer" target="_blank">
          {row.original.title}
        </a>
        <p>{row.original.summary}</p>
      </div>
    ),
  },
  {
    accessorKey: "source",
    header: "Source",
    cell: ({ row }) => (
      <Badge variant="outline">{row.original.source === "github" ? "GitHub" : "Hacker News"}</Badge>
    ),
  },
  {
    accessorKey: "engagementCount",
    header: "Engagement",
  },
  {
    accessorKey: "score",
    header: "Score",
    cell: ({ row }) => row.original.score.toFixed(1),
  },
  {
    accessorKey: "keywords",
    header: "Keywords",
    cell: ({ row }) => (
      <div className="dashboard-route__keyword-list">
        {row.original.keywords.map((keyword) => (
          <Badge key={keyword} variant="secondary">
            {keyword}
          </Badge>
        ))}
      </div>
    ),
  },
];

export function RankedItemsTable({ items }: RankedItemsTableProps) {
  return (
    <DataTableLayout
      columns={columns}
      data={items}
      toolbar={<p className="dashboard-route__table-note">Fixture-backed feed. Supabase persistence boundary is in place for the next slice.</p>}
      emptyDescription="Adjust sources or keyword filters to bring candidate signals back into scope."
      emptyTitle="No signals match the current filters"
    />
  );
}
