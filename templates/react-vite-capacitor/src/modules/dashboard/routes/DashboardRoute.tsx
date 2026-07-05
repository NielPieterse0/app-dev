import { PageHeader } from "../../../app/PageHeader";
import { DataTableLayout } from "../../../components/layout/DataTableLayout";
import { ListDetailLayout } from "../../../components/layout/ListDetailLayout";
import "./dashboard-route.css";

const modules = [
  { name: "Planning", status: "Ready" },
  { name: "Data model", status: "Draft" },
  { name: "Verification", status: "Ready" },
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
          <DataTableLayout toolbar={<button type="button">New module</button>}>
            <table>
              <thead>
                <tr>
                  <th>Module</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {modules.map((module) => (
                  <tr key={module.name}>
                    <td>{module.name}</td>
                    <td>{module.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </DataTableLayout>
        }
      />
    </div>
  );
}
