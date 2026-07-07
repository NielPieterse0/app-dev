import { Outlet, useLocation } from "react-router-dom";
import { PageHeader } from "../../../app/PageHeader";
import { FormLayoutExample } from "../../../components/layout/FormLayout";
import { SettingsLayout } from "../../../components/layout/SettingsLayout";
import { useAuthSession } from "../../auth";

const settingsItems = [
  { label: "General", href: "/settings" },
  { label: "Notifications", href: "/settings/notifications" },
  { label: "Protected", href: "/settings/protected" },
];

export function SettingsRoute() {
  const { pathname } = useLocation();
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
        items={settingsItems.map((item) => ({
          ...item,
          isActive: pathname === item.href,
        }))}
      >
        <Outlet />
      </SettingsLayout>
    </section>
  );
}

export function SettingsGeneralRoute() {
  return (
    <div>
      <p>Replace this starter route with real settings workflows when the product decision record defines them.</p>
      <FormLayoutExample />
    </div>
  );
}

export function SettingsNotificationsRoute() {
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
