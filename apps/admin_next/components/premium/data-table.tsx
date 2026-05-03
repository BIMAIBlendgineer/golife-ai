import { cn } from "@/lib/cn";

export type DataColumn<Row> = {
  id: string;
  header: React.ReactNode;
  cell: (row: Row) => React.ReactNode;
  className?: string;
  headerClassName?: string;
};

export function DataTable<Row>({
  columns,
  rows,
  rowKey,
  emptyState,
}: {
  columns: Array<DataColumn<Row>>;
  rows: Row[];
  rowKey: (row: Row, index: number) => string;
  emptyState?: React.ReactNode;
}) {
  if (rows.length === 0 && emptyState) {
    return <>{emptyState}</>;
  }

  return (
    <div className="overflow-x-auto rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)]">
      <table className="min-w-full border-collapse">
        <thead>
          <tr className="border-b border-[color:var(--line)] bg-[color:var(--surface-2)]">
            {columns.map((column) => (
              <th
                key={column.id}
                className={cn(
                  "px-4 py-3 text-left text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]",
                  column.headerClassName,
                )}
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, index) => (
            <tr
              key={rowKey(row, index)}
              className="border-b border-[color:var(--line)] last:border-b-0 hover:bg-[color:rgba(19,24,23,0.02)]"
            >
              {columns.map((column) => (
                <td key={column.id} className={cn("px-4 py-3 align-top", column.className)}>
                  {column.cell(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
