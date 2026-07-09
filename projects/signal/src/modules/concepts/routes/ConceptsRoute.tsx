import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { EmptyState, ErrorState, LoadingState } from "@/components/state";
import { ListDetailLayout } from "@/components/layout/ListDetailLayout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { PageHeader } from "@/app/PageHeader";
import { sourceLabels } from "@/modules/sources";
import { useConcepts, useSaveConcept } from "../hooks/useConcepts";
import { buildConceptExportPayload, buildConceptMarkdown } from "../services/concept-export";
import { normalizeConceptDraft, type SignalConcept } from "../schemas/concept.schema";

async function copyText(value: string) {
  if (typeof navigator === "undefined" || !navigator.clipboard?.writeText) {
    return false;
  }

  await navigator.clipboard.writeText(value);
  return true;
}

function createNextSelectionId(concepts: SignalConcept[], selectedConceptId: string | null) {
  if (!concepts.length) {
    return null;
  }

  return concepts.some((concept) => concept.id === selectedConceptId)
    ? selectedConceptId
    : concepts[0].id;
}

export function ConceptsRoute() {
  const { concepts, backend, degradedReason, isLoading, error: loadError } = useConcepts();
  const { isSaving, error: saveError, saveConcept } = useSaveConcept();
  const [searchParams, setSearchParams] = useSearchParams();
  const selectedConceptId = searchParams.get("concept");
  const nextSelectionId = createNextSelectionId(concepts, selectedConceptId);
  const selectedConcept = useMemo(
    () => concepts.find((concept) => concept.id === nextSelectionId) ?? null,
    [concepts, nextSelectionId]
  );
  const [draft, setDraft] = useState<SignalConcept | null>(null);
  const [isDirty, setIsDirty] = useState(false);
  const [saveMessage, setSaveMessage] = useState<string | null>(null);
  const [exportMessage, setExportMessage] = useState<string | null>(null);
  const error = saveError ?? loadError;

  useEffect(() => {
    if (nextSelectionId && nextSelectionId !== selectedConceptId) {
      setSearchParams({ concept: nextSelectionId }, { replace: true });
    }
  }, [nextSelectionId, selectedConceptId, setSearchParams]);

  useEffect(() => {
    setDraft(selectedConcept);
    setIsDirty(false);
    setSaveMessage(null);
    setExportMessage(null);
  }, [selectedConcept]);

  async function handleSaveConcept() {
    if (!draft) {
      return;
    }

    const nextConcept = normalizeConceptDraft(draft, {});
    const savedConcept = await saveConcept(nextConcept);
    setDraft(savedConcept.concept);
    setIsDirty(false);
    setSaveMessage(
      savedConcept.backend === "local-fallback"
        ? "Concept saved in the local fallback workspace."
        : "Concept saved in the configured remote workspace."
    );
  }

  async function handleCopyMarkdown() {
    if (!draft) {
      return;
    }

    const copied = await copyText(buildConceptMarkdown(draft));
    setExportMessage(copied ? "Markdown brief copied to the clipboard." : "Markdown preview is ready below.");
  }

  async function handleCopyJson() {
    if (!draft) {
      return;
    }

    const copied = await copyText(JSON.stringify(buildConceptExportPayload(draft), null, 2));
    setExportMessage(copied ? "JSON payload copied to the clipboard." : "JSON preview is ready below.");
  }

  function updateDraft(
    field: "title" | "targetUser" | "problem" | "opportunity" | "evidenceSummary" | "risks" | "confidence" | "status",
    value: string
  ) {
    if (!draft) {
      return;
    }

    setDraft(
      normalizeConceptDraft(draft, {
        [field]: value,
      })
    );
    setIsDirty(true);
    setSaveMessage(null);
  }

  const markdownPreview = draft ? buildConceptMarkdown(draft) : "";
  const jsonPreview = draft ? JSON.stringify(buildConceptExportPayload(draft), null, 2) : "";

  return (
    <section className="space-y-6">
      <PageHeader
        title="Concept workbench"
        description="Turn reviewed live signals into durable product briefs without mutating the local workspace from inside the app."
      />
      <div className="space-y-2">
        <p>
          Concept storage:{" "}
          {backend === "supabase"
            ? "configured remote workspace with local fallback available when needed"
            : "local fallback workspace while the configured remote backend is unavailable or unconfigured"}
        </p>
        {degradedReason ? (
          <p className="text-sm text-muted-foreground">Degraded mode reason: {degradedReason}</p>
        ) : null}
      </div>

      {isLoading ? <LoadingState label="Loading concept drafts" /> : null}
      {error ? <ErrorState title="Could not load concept drafts" description={error.message} /> : null}

      {!isLoading && !error ? (
        <ListDetailLayout
          list={
            <section className="space-y-3">
              <h2 className="text-lg font-semibold">Promoted concepts</h2>
              {concepts.length ? (
                <div className="space-y-2">
                  {concepts.map((concept) => (
                    <button
                      key={concept.id}
                      type="button"
                      className={`w-full rounded-lg border p-3 text-left ${
                        concept.id === nextSelectionId ? "border-foreground" : ""
                      }`}
                      onClick={() => setSearchParams({ concept: concept.id })}
                    >
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="font-medium">{concept.title}</span>
                        <Badge variant="outline">{concept.status}</Badge>
                        <Badge variant="secondary">{concept.confidence}</Badge>
                      </div>
                      <p className="mt-2 text-sm text-muted-foreground">
                        {concept.sourceItemIds.length} linked signal{concept.sourceItemIds.length === 1 ? "" : "s"}
                      </p>
                    </button>
                  ))}
                </div>
              ) : (
                <EmptyState
                  title="No concepts yet"
                  description="Promote a reviewed signal from the dashboard to start the concept workbench."
                />
              )}
            </section>
          }
          detail={
            draft ? (
              <section className="space-y-4">
                <div>
                  <h2 className="text-lg font-semibold">Concept brief</h2>
                  <p className="text-sm text-muted-foreground">
                    Review the linked evidence, then shape the concept into a build-ready brief.
                  </p>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <label className="space-y-2">
                    <span className="text-sm font-medium">Title</span>
                    <Input
                      value={draft.title}
                      onChange={(event) => updateDraft("title", event.target.value)}
                    />
                  </label>
                  <label className="space-y-2">
                    <span className="text-sm font-medium">Target user</span>
                    <Input
                      value={draft.targetUser}
                      onChange={(event) => updateDraft("targetUser", event.target.value)}
                    />
                  </label>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <label className="space-y-2">
                    <span className="text-sm font-medium">Status</span>
                    <select
                      className="w-full rounded-md border bg-background px-3 py-2 text-sm"
                      value={draft.status}
                      onChange={(event) => updateDraft("status", event.target.value)}
                    >
                      <option value="draft">draft</option>
                      <option value="reviewing">reviewing</option>
                      <option value="ready">ready</option>
                      <option value="archived">archived</option>
                    </select>
                  </label>
                  <label className="space-y-2">
                    <span className="text-sm font-medium">Confidence</span>
                    <select
                      className="w-full rounded-md border bg-background px-3 py-2 text-sm"
                      value={draft.confidence}
                      onChange={(event) => updateDraft("confidence", event.target.value)}
                    >
                      <option value="low">low</option>
                      <option value="medium">medium</option>
                      <option value="high">high</option>
                    </select>
                  </label>
                </div>

                <label className="space-y-2">
                  <span className="text-sm font-medium">Problem</span>
                  <textarea
                    className="min-h-24 w-full rounded-md border bg-background px-3 py-2 text-sm"
                    value={draft.problem}
                    onChange={(event) => updateDraft("problem", event.target.value)}
                  />
                </label>

                <label className="space-y-2">
                  <span className="text-sm font-medium">Opportunity</span>
                  <textarea
                    className="min-h-24 w-full rounded-md border bg-background px-3 py-2 text-sm"
                    value={draft.opportunity}
                    onChange={(event) => updateDraft("opportunity", event.target.value)}
                  />
                </label>

                <label className="space-y-2">
                  <span className="text-sm font-medium">Evidence summary</span>
                  <textarea
                    className="min-h-24 w-full rounded-md border bg-background px-3 py-2 text-sm"
                    value={draft.evidenceSummary}
                    onChange={(event) => updateDraft("evidenceSummary", event.target.value)}
                  />
                </label>

                <label className="space-y-2">
                  <span className="text-sm font-medium">Risks</span>
                  <textarea
                    className="min-h-24 w-full rounded-md border bg-background px-3 py-2 text-sm"
                    value={draft.risks}
                    onChange={(event) => updateDraft("risks", event.target.value)}
                  />
                </label>

                <section className="space-y-3 rounded-lg border p-4">
                  <h3 className="font-medium">Linked evidence</h3>
                  <div className="space-y-3">
                    {draft.evidenceItems.map((item) => (
                      <div key={item.id} className="rounded-md border p-3">
                        <div className="flex flex-wrap items-center gap-2">
                          <Badge variant="outline">{sourceLabels[item.source]}</Badge>
                          <Badge variant="secondary">Score {item.score.toFixed(1)}</Badge>
                          <Badge variant="secondary">Engagement {item.engagementCount}</Badge>
                        </div>
                        <p className="mt-2 font-medium">{item.title}</p>
                        <p className="text-sm text-muted-foreground">{item.summary}</p>
                      </div>
                    ))}
                  </div>
                </section>

                <div aria-live="polite" className="space-y-2 text-sm">
                  {saveMessage ? <p>{saveMessage}</p> : null}
                  {exportMessage ? <p>{exportMessage}</p> : null}
                </div>

                <div className="flex flex-wrap items-center gap-3">
                  <Button type="button" onClick={() => void handleSaveConcept()} disabled={!isDirty || isSaving}>
                    {isSaving ? "Saving concept..." : "Save concept"}
                  </Button>
                  <Button type="button" variant="outline" onClick={() => void handleCopyMarkdown()}>
                    Copy Markdown
                  </Button>
                  <Button type="button" variant="outline" onClick={() => void handleCopyJson()}>
                    Copy JSON
                  </Button>
                </div>

                <section className="space-y-3 rounded-lg border p-4">
                  <h3 className="font-medium">Markdown export preview</h3>
                  <pre className="overflow-x-auto whitespace-pre-wrap text-sm">{markdownPreview}</pre>
                </section>

                <section className="space-y-3 rounded-lg border p-4">
                  <h3 className="font-medium">JSON export preview</h3>
                  <pre className="overflow-x-auto whitespace-pre-wrap text-sm">{jsonPreview}</pre>
                </section>
              </section>
            ) : (
              <EmptyState
                title="No concept selected"
                description="Promote a signal from the dashboard or choose an existing concept draft from the list."
              />
            )
          }
        />
      ) : null}
    </section>
  );
}
