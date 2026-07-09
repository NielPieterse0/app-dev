import { useEffect, useState } from "react";
import { Outlet, useLocation, useOutletContext } from "react-router-dom";
import { PageHeader } from "@/app/PageHeader";
import { SettingsLayout } from "@/components/layout/SettingsLayout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  getEnabledKeywordFilters,
  useSourcePreferencesStore,
  useSourceSettings,
  type SettingsBackend,
} from "@/modules/sources";

const settingsItems = [
  { label: "Sources", href: "/settings" },
  { label: "Keywords", href: "/settings/keywords" },
];

type SettingsRouteContext = {
  backend: SettingsBackend;
  canSave: boolean;
  degradedReason: string | null;
  enabledSources: ("github" | "hacker_news")[];
  errorMessage: string | null;
  includeKeywordsText: string;
  isDirty: boolean;
  isLoading: boolean;
  isSaving: boolean;
  saveMessage: string | null;
  saveSettings: () => Promise<void>;
  setIncludeKeywordsText: (value: string) => void;
  setSourceEnabled: (source: "github" | "hacker_news", enabled: boolean) => void;
};

export function SettingsRoute() {
  const { pathname } = useLocation();
  const enabledSources = useSourcePreferencesStore((state) => state.enabledSources);
  const hasHydrated = useSourcePreferencesStore((state) => state.hasHydrated);
  const includeKeywordsText = useSourcePreferencesStore((state) => state.includeKeywordsText);
  const isDirty = useSourcePreferencesStore((state) => state.isDirty);
  const hydrateFromSettings = useSourcePreferencesStore((state) => state.hydrateFromSettings);
  const setSourceEnabled = useSourcePreferencesStore((state) => state.setSourceEnabled);
  const setIncludeKeywordsText = useSourcePreferencesStore((state) => state.setIncludeKeywordsText);
  const { settings, backend, degradedReason, isLoading, isSaving, error, saveSettings } =
    useSourceSettings();
  const [routeErrorMessage, setRouteErrorMessage] = useState<string | null>(null);
  const [saveMessage, setSaveMessage] = useState<string | null>(null);

  useEffect(() => {
    hydrateFromSettings(settings, {
      force: !hasHydrated,
    });
  }, [hasHydrated, hydrateFromSettings, settings]);

  useEffect(() => {
    if (error) {
      setSaveMessage(null);
    }
  }, [error]);

  const saveErrorMessage = routeErrorMessage ?? error?.message ?? null;

  async function handleSaveSettings() {
    setSaveMessage(null);
    setRouteErrorMessage(null);

    try {
      const nextData = await saveSettings({
        enabledSources,
        includeKeywords: getEnabledKeywordFilters(includeKeywordsText),
      });

      hydrateFromSettings(nextData.settings, { force: true });
      setSaveMessage(
        nextData.backend === "local-fallback"
          ? "Saved locally while the configured remote workspace is unavailable."
          : "Settings saved in the configured remote workspace."
      );
    } catch (saveError) {
      setRouteErrorMessage(
        saveError instanceof Error ? saveError.message : "Settings could not be saved."
      );
    }
  }

  const canSave = enabledSources.length > 0 && !isLoading && !isSaving;
  const context: SettingsRouteContext = {
    backend,
    canSave,
    degradedReason,
    enabledSources,
    errorMessage: saveErrorMessage,
    includeKeywordsText,
    isDirty,
    isLoading,
    isSaving,
    saveMessage,
    saveSettings: handleSaveSettings,
    setIncludeKeywordsText,
    setSourceEnabled,
  };

  return (
    <section>
      <PageHeader
        title="Signal settings"
        description="Control source scope, keyword pressure, and free-tier operating assumptions."
      />
      <div className="space-y-2">
        <p>
          Settings storage:{" "}
          {backend === "supabase"
            ? "configured remote workspace with publishable browser keys"
            : "local fallback while the configured remote workspace is unavailable or unconfigured"}
        </p>
        {degradedReason ? (
          <p className="text-sm text-muted-foreground">
            Degraded mode reason: {degradedReason}
          </p>
        ) : null}
      </div>
      <SettingsLayout
        items={settingsItems.map((item) => ({
          ...item,
          isActive: pathname === item.href,
        }))}
      >
        <Outlet context={context} />
      </SettingsLayout>
    </section>
  );
}

function useSettingsRouteContext() {
  return useOutletContext<SettingsRouteContext>();
}

export function SettingsSourcesRoute() {
  const {
    backend,
    canSave,
    enabledSources,
    errorMessage,
    isDirty,
    isLoading,
    isSaving,
    saveMessage,
    saveSettings,
    setSourceEnabled,
  } = useSettingsRouteContext();

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
          const disableToggle = enabled && enabledSources.length === 1;

          return (
            <Button
              key={source.key}
              type="button"
              aria-pressed={enabled}
              variant={enabled ? "default" : "outline"}
              disabled={isLoading || isSaving || disableToggle}
              onClick={() => setSourceEnabled(source.key as "github" | "hacker_news", !enabled)}
            >
              {enabled ? "Enabled" : "Disabled"} {source.label}
            </Button>
          );
        })}
      </div>

      <div aria-live="polite" className="space-y-2 text-sm">
        {saveMessage ? <p>{saveMessage}</p> : null}
        {errorMessage ? <p className="text-destructive">{errorMessage}</p> : null}
        {backend === "local-fallback" ? (
          <p className="text-muted-foreground">
            Signal is in local fallback mode. Changes stay in this browser until the configured remote workspace is reachable again.
          </p>
        ) : null}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <Button type="button" disabled={!canSave} onClick={() => void saveSettings()}>
          {isSaving ? "Saving settings..." : "Save source settings"}
        </Button>
        {isDirty ? <p className="text-sm text-muted-foreground">Unsaved draft changes.</p> : null}
      </div>

      <div className="rounded-lg border p-4">
        <h3 className="font-medium">Operating boundary</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Signal stays on free-tier infrastructure until the product is proven. This slice documents the risk that the configured remote backend can pause after inactivity and does not assume always-on availability.
        </p>
      </div>
    </div>
  );
}

export function SettingsKeywordsRoute() {
  const {
    backend,
    canSave,
    errorMessage,
    includeKeywordsText,
    isDirty,
    isLoading,
    isSaving,
    saveMessage,
    saveSettings,
    setIncludeKeywordsText,
  } = useSettingsRouteContext();
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
        disabled={isLoading || isSaving}
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

      <div aria-live="polite" className="space-y-2 text-sm">
        {saveMessage ? <p>{saveMessage}</p> : null}
        {errorMessage ? <p className="text-destructive">{errorMessage}</p> : null}
        {backend === "local-fallback" ? (
          <p className="text-muted-foreground">
            Keyword changes are saving to the local fallback store until the configured remote workspace is available.
          </p>
        ) : null}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <Button type="button" disabled={!canSave} onClick={() => void saveSettings()}>
          {isSaving ? "Saving settings..." : "Save keyword settings"}
        </Button>
        {isDirty ? <p className="text-sm text-muted-foreground">Unsaved draft changes.</p> : null}
      </div>

      <div className="rounded-lg border p-4">
        <h3 className="font-medium">Next-step note</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Keyword filters persist through the same settings repository boundary as source toggles. Public launch still requires a stricter auth and RLS model.
        </p>
      </div>
    </div>
  );
}
