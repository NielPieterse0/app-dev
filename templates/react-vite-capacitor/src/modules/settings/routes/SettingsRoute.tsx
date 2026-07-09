import { Outlet } from "react-router-dom";
import { useAuthSession } from "@/modules/auth";
import { PageHeader } from "../../../app/PageHeader";
import { FormLayoutExample } from "../../../components/layout/FormLayout";
import { SettingsLayout } from "../../../components/layout/SettingsLayout";

// Disposable example settings scaffolding. Rename or remove these routes once the
// real product settings flows are defined for the generated app.
const settingsItems = [
  { label: "General", href: "/settings" },
  { label: "Notifications", href: "/settings/notifications" },
  { label: "Protected", href: "/settings/protected" },
];

export function SettingsExampleRoute() {
  const { session, isLoading } = useAuthSession();

  return (
    <section>
      <PageHeader
        title="Settings"
        description="Configure app-level preferences, integrations, and operational defaults."
      />
      <p>
        Auth example status:{" "}
        {isLoading ? "checking session" : session ? "signed in" : "not signed in or Supabase not configured"}
      </p>
      <SettingsLayout
        items={settingsItems}
      >
        <Outlet />
      </SettingsLayout>
    </section>
  );
}

export function SettingsGeneralExampleRoute() {
  return (
    <div>
      <p>Replace this starter route with real settings workflows when the product decision record defines them.</p>
      <FormLayoutExample />
    </div>
  );
}

export function SettingsNotificationsExampleRoute() {
  return (
    <div>
      <h2>Notification defaults</h2>
      <p>Use this section to document alert channels, digest cadence, and operational ownership defaults.</p>
    </div>
  );
}

export function ProtectedSettingsExampleRoute() {
  return (
    <div>
      <h2>Protected settings example</h2>
      <p>This route is loader-guarded to demonstrate how a generated app can require a Supabase session.</p>
    </div>
  );
}
