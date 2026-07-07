import type { ReactNode } from "react";
import {
  flexRender,
  getCoreRowModel,
  getPaginationRowModel,
  useReactTable,
  type ColumnDef,
} from "@tanstack/react-table";
import { EmptyState } from "../state";
import { Button } from "../ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "../ui/table";
import "./layouts.css";

type DataTableLayoutProps<TData, TValue> = {
  columns: ColumnDef<TData, TValue>[];
  data: TData[];
  toolbar?: ReactNode;
  emptyTitle?: string;
  emptyDescription?: string;
};

export function DataTableLayout<TData, TValue>({
  columns,
  data,
  toolbar,
  emptyTitle = "No rows available",
  emptyDescription = "Add real module data when the product decision record defines the entity shape.",
}: DataTableLayoutProps<TData, TValue>) {
  const table = useReactTable({
    columns,
    data,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  const rows = table.getRowModel().rows;

  return (
    <section className="data-table-layout">
      {toolbar ? <div className="data-table-layout__toolbar">{toolbar}</div> : null}
      <div className="data-table-layout__body">
        {rows.length ? (
          <Table>
            <TableHeader>
              {table.getHeaderGroups().map((headerGroup) => (
                <TableRow key={headerGroup.id}>
                  {headerGroup.headers.map((header) => (
                    <TableHead key={header.id}>
                      {header.isPlaceholder
                        ? null
                        : flexRender(header.column.columnDef.header, header.getContext())}
                    </TableHead>
                  ))}
                </TableRow>
              ))}
            </TableHeader>
            <TableBody>
              {rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        ) : (
          <EmptyState title={emptyTitle} description={emptyDescription} />
        )}
      </div>
      <div className="data-table-layout__footer">
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Previous
        </Button>
        <span className="data-table-layout__page">
          Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
        </span>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => table.nextPage()}
          disabled={!table.getCanNextPage()}
        >
          Next
        </Button>
      </div>
    </section>
  );
}
