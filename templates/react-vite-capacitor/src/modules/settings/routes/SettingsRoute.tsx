import { PageHeader } from "../../../app/PageHeader";
import { useAuthSession } from "../../auth";

export function SettingsRoute() {
  const { session, isLoading } = useAuthSession();

  return (
    <section>
      <PageHeader
        title="Settings"
        description="Configure app-level preferences, integrations, and operational defaults."
      />
      <p>Replace this starter route with real settings workflows when the product decision record defines them.</p>
      <p>
        Auth example status:{" "}
        {isLoading ? "checking session" : session ? "signed in" : "not signed in or Supabase not configured"}
      </p>
      <p>
        Protected route example: visit <code>/settings/protected</code> after wiring a real Supabase project and auth flow.
      </p>
    </section>
  );
}

export function ProtectedSettingsExampleRoute() {
  return (
    <section>
      <PageHeader
        title="Protected settings example"
        description="This route is loader-guarded to demonstrate how a generated app can require a Supabase session."
      />
      <p>Use this route as the reference seam for product-specific protected settings sections.</p>
    </section>
  );
}
