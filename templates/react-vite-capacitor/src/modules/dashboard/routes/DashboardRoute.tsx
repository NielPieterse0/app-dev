import { PageHeader } from "../../../app/PageHeader";
import { DataTableLayout } from "../../../components/layout/DataTableLayout";
import { ListDetailLayout } from "../../../components/layout/ListDetailLayout";
import "./dashboard-route.css";

const modules = [
  { name: "Planning", status: "Ready" },
  { name: "Data model", status: "Draft" },
  { name: "Verification", status: "Ready" },
];

const moduleColumns = [
  {
    accessorKey: "name",
    header: "Module",
  },
  {
    accessorKey: "status",
    header: "Status",
  },
];

export function DashboardRoute() {
  return (
    <div className="dashboard-route">
      <PageHeader
        title="Workspace starter"
        description="A minimal operational surface for the first product module."
      />
      <ListDetailLayout
        list={
          <ul className="dashboard-route__list">
            {modules.map((module) => (
              <li key={module.name}>
                <span>{module.name}</span>
                <strong>{module.status}</strong>
              </li>
            ))}
          </ul>
        }
        detail={
          <DataTableLayout columns={moduleColumns} data={modules} toolbar={<button type="button">New module</button>} />
        }
      />
    </div>
  );
}
