import type { ColumnDef } from "@tanstack/react-table";
import { Badge } from "../../../components/ui/badge";
import { Button } from "../../../components/ui/button";
import { DataTableLayout } from "../../../components/layout/DataTableLayout";
import { sourceLabels, type NormalizedSourceItem } from "@/modules/sources";

type RankedItemsTableProps = {
  backend: "supabase" | "local-fallback";
  items: NormalizedSourceItem[];
  onInspect: (item: NormalizedSourceItem) => void;
  selectedSignalId: string | null;
};

function createColumns(
  onInspect: (item: NormalizedSourceItem) => void,
  selectedSignalId: string | null
): ColumnDef<NormalizedSourceItem>[] {
  return [
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
      cell: ({ row }) => <Badge variant="outline">{sourceLabels[row.original.source]}</Badge>,
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
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }) => (
        <Button
          type="button"
          variant={selectedSignalId === row.original.id ? "default" : "outline"}
          onClick={() => onInspect(row.original)}
        >
          {selectedSignalId === row.original.id ? "Inspecting" : "Inspect"}
        </Button>
      ),
    },
  ];
}

export function RankedItemsTable({
  backend,
  items,
  onInspect,
  selectedSignalId,
}: RankedItemsTableProps) {
  return (
    <DataTableLayout
      columns={createColumns(onInspect, selectedSignalId)}
      data={items}
      toolbar={
        <p className="dashboard-route__table-note">
          {backend === "supabase"
            ? "Persisted feed from the configured remote workspace."
            : "Persisted local fallback feed. Refreshes stay in this browser until the configured remote workspace is reachable."}
        </p>
      }
      emptyDescription="Adjust sources or keyword filters to bring candidate signals back into scope."
      emptyTitle="No signals match the current filters"
    />
  );
}
