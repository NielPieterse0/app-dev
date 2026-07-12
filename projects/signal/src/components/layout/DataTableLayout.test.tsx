import { render, screen } from "@testing-library/react";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTableLayout } from "./DataTableLayout";

type Row = {
  name: string;
  status: string;
};

const columns: ColumnDef<Row>[] = [
  {
    accessorKey: "name",
    header: "Module",
  },
  {
    accessorKey: "status",
    header: "Status",
  },
];

test("DataTableLayout renders columns and rows", () => {
  render(
    <DataTableLayout
      columns={columns}
      data={[
        { name: "Planning", status: "ready" },
        { name: "Verification", status: "draft" },
      ]}
    />
  );

  expect(screen.getByRole("columnheader", { name: "Module" })).toBeInTheDocument();
  expect(screen.getByRole("cell", { name: "Planning" })).toBeInTheDocument();
  expect(screen.getByRole("cell", { name: "draft" })).toBeInTheDocument();
});

test("DataTableLayout renders an empty state with no rows", () => {
  render(<DataTableLayout columns={columns} data={[]} />);

  expect(screen.getByRole("region", { name: "No rows available" })).toBeInTheDocument();
});
