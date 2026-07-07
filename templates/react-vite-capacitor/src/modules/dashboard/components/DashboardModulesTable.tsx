import type { ColumnDef } from "@tanstack/react-table";
import { DataTableLayout } from "../../../components/layout/DataTableLayout";
import type { DashboardModule } from "../schemas/dashboard-module.schema";

type DashboardModulesTableProps = {
  modules: DashboardModule[];
};

const columns: ColumnDef<DashboardModule>[] = [
  {
    accessorKey: "name",
    header: "Module",
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => row.original.status,
  },
];

export function DashboardModulesTable({ modules }: DashboardModulesTableProps) {
  return (
    <DataTableLayout
      columns={columns}
      data={modules}
      toolbar={<button type="button">New module</button>}
      emptyDescription="Add dashboard modules when the product decision record defines them."
      emptyTitle="No modules yet"
    />
  );
}
