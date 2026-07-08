import { Outlet, useLocation } from "react-router-dom";
import { Badge } from "../../../components/ui/badge";
import { Button } from "../../../components/ui/button";
import { Input } from "../../../components/ui/input";
import { PageHeader } from "../../../app/PageHeader";
import { SettingsLayout } from "../../../components/layout/SettingsLayout";
import { isSupabaseConfigured } from "../../../lib/env";
import { getEnabledKeywordFilters, useSourcePreferencesStore } from "@/modules/sources";

const settingsItems = [
  { label: "Sources", href: "/settings" },
  { label: "Keywords", href: "/settings/keywords" },
];

export function SettingsRoute() {
  const { pathname } = useLocation();
  const supabaseConfigured = isSupabaseConfigured();

  return (
    <section>
      <PageHeader
        title="Signal settings"
        description="Control source scope, keyword pressure, and free-tier operating assumptions."
      />
      <p>
        Supabase browser client: {supabaseConfigured ? "configured with publishable keys" : "not configured, using fixtures only"}
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

export function SettingsSourcesRoute() {
  const enabledSources = useSourcePreferencesStore((state) => state.enabledSources);
  const setSourceEnabled = useSourcePreferencesStore((state) => state.setSourceEnabled);

  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-lg font-semibold">Tracked sources</h2>
        <p className="text-sm text-muted-foreground">
          Keep the slice narrow. Signal only tracks public GitHub and Hacker News items until the adapter pattern proves itself.
        </p>
      </div>

      <div className="flex flex-wrap gap-3">
        {[
          { key: "github", label: "GitHub" },
          { key: "hacker_news", label: "Hacker News" },
        ].map((source) => {
          const enabled = enabledSources.includes(source.key as "github" | "hacker_news");

          return (
            <Button
              key={source.key}
              type="button"
              variant={enabled ? "default" : "outline"}
              onClick={() => setSourceEnabled(source.key as "github" | "hacker_news", !enabled)}
            >
              {enabled ? "Enabled" : "Disabled"} {source.label}
            </Button>
          );
        })}
      </div>

      <div className="rounded-lg border p-4">
        <h3 className="font-medium">Operating boundary</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Signal stays on free-tier infrastructure until the product is proven. This slice documents the risk that Supabase can pause after inactivity and does not assume always-on backend availability.
        </p>
      </div>
    </div>
  );
}

export function SettingsKeywordsRoute() {
  const includeKeywordsText = useSourcePreferencesStore((state) => state.includeKeywordsText);
  const setIncludeKeywordsText = useSourcePreferencesStore((state) => state.setIncludeKeywordsText);
  const keywords = getEnabledKeywordFilters(includeKeywordsText);

  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-lg font-semibold">Keyword pressure</h2>
        <p className="text-sm text-muted-foreground">
          Use comma-separated keywords to narrow Signal toward domains worth converting into future product concepts.
        </p>
      </div>

      <Input
        aria-label="Keyword filters"
        placeholder="agents, founder-tools, research"
        value={includeKeywordsText}
        onChange={(event) => setIncludeKeywordsText(event.target.value)}
      />

      <div className="flex flex-wrap gap-2">
        {keywords.length ? (
          keywords.map((keyword) => (
            <Badge key={keyword} variant="secondary">
              {keyword}
            </Badge>
          ))
        ) : (
          <p className="text-sm text-muted-foreground">No keyword filter applied. Signal is using the full public-source seed set.</p>
        )}
      </div>

      <div className="rounded-lg border p-4">
        <h3 className="font-medium">Next-step note</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Keyword filters stay local for this slice. Persisting them through Supabase is a follow-on change once the baseline source model is stable.
        </p>
      </div>
    </div>
  );
}
