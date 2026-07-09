import { z } from "zod";
import { signalConceptSchema, signalConceptsSchema, type SignalConcept } from "../schemas/concept.schema";

export type ConceptsBackend = "supabase" | "local-fallback";

export type SignalConceptRepository = {
  list(): Promise<SignalConcept[]>;
  save(concept: SignalConcept): Promise<SignalConcept>;
};

export const conceptsQueryKey = ["signal-concepts"] as const;

const signalConceptRowSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  target_user: z.string(),
  problem: z.string(),
  opportunity: z.string(),
  evidence_summary: z.string(),
  risks: z.string(),
  confidence: z.enum(["low", "medium", "high"]),
  status: z.enum(["draft", "reviewing", "ready", "archived"]),
  source_item_ids: z.array(z.string()).default([]),
  evidence_items: z.array(z.unknown()).default([]),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
});

const signalConceptRpcResultSchema = signalConceptRowSchema;

export function orderConcepts(concepts: SignalConcept[]) {
  return signalConceptsSchema.parse(
    [...concepts].sort((left, right) => {
      return new Date(right.updatedAt).getTime() - new Date(left.updatedAt).getTime();
    })
  );
}

export function mapConceptRow(row: unknown): SignalConcept {
  const parsedRow = signalConceptRowSchema.parse(row);

  return signalConceptSchema.parse({
    id: parsedRow.id,
    title: parsedRow.title,
    targetUser: parsedRow.target_user,
    problem: parsedRow.problem,
    opportunity: parsedRow.opportunity,
    evidenceSummary: parsedRow.evidence_summary,
    risks: parsedRow.risks,
    confidence: parsedRow.confidence,
    status: parsedRow.status,
    sourceItemIds: parsedRow.source_item_ids,
    evidenceItems: parsedRow.evidence_items,
    createdAt: parsedRow.created_at,
    updatedAt: parsedRow.updated_at,
  });
}

export function mapConceptRows(rows: unknown): SignalConcept[] {
  const parsedRows = z.array(signalConceptRowSchema).parse(rows);
  return orderConcepts(parsedRows.map((row) => mapConceptRow(row)));
}

export function mapConceptRpcPayload(payload: unknown) {
  return mapConceptRow(signalConceptRpcResultSchema.parse(payload));
}

export function createConceptRow(concept: SignalConcept) {
  const parsedConcept = signalConceptSchema.parse(concept);

  return {
    id: parsedConcept.id,
    title: parsedConcept.title,
    target_user: parsedConcept.targetUser,
    problem: parsedConcept.problem,
    opportunity: parsedConcept.opportunity,
    evidence_summary: parsedConcept.evidenceSummary,
    risks: parsedConcept.risks,
    confidence: parsedConcept.confidence,
    status: parsedConcept.status,
    source_item_ids: parsedConcept.sourceItemIds,
    evidence_items: parsedConcept.evidenceItems,
    created_at: parsedConcept.createdAt,
    updated_at: parsedConcept.updatedAt,
  };
}

