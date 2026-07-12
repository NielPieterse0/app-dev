import { z } from "zod";
import { normalizedSourceItemSchema, type NormalizedSourceItem } from "@/modules/sources";

export const conceptStatusSchema = z.enum(["draft", "reviewing", "ready", "archived"]);
export const conceptConfidenceSchema = z.enum(["low", "medium", "high"]);

export const conceptEvidenceItemSchema = normalizedSourceItemSchema;

export const signalConceptSchema = z.object({
  id: z.string().min(1),
  title: z.string().trim().min(1),
  targetUser: z.string().trim(),
  problem: z.string().trim(),
  opportunity: z.string().trim(),
  evidenceSummary: z.string().trim(),
  risks: z.string().trim(),
  confidence: conceptConfidenceSchema,
  status: conceptStatusSchema,
  sourceItemIds: z.array(z.string().min(1)).min(1),
  evidenceItems: z.array(conceptEvidenceItemSchema).min(1),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

export const signalConceptsSchema = z.array(signalConceptSchema);

export type ConceptConfidence = z.infer<typeof conceptConfidenceSchema>;
export type ConceptStatus = z.infer<typeof conceptStatusSchema>;
export type ConceptEvidenceItem = z.infer<typeof conceptEvidenceItemSchema>;
export type SignalConcept = z.infer<typeof signalConceptSchema>;

function deriveConceptConfidence(score: number): ConceptConfidence {
  if (score >= 30) {
    return "high";
  }

  if (score >= 15) {
    return "medium";
  }

  return "low";
}

export function createConceptDraftFromSourceItem(
  item: NormalizedSourceItem,
  now = new Date()
): SignalConcept {
  const timestamp = now.toISOString();

  return signalConceptSchema.parse({
    id: crypto.randomUUID(),
    title: item.title,
    targetUser: "",
    problem: "",
    opportunity: item.summary,
    evidenceSummary: `Derived from ${item.source === "github" ? "GitHub" : "Hacker News"} signal "${item.title}" with score ${item.score.toFixed(1)} and engagement ${item.engagementCount}.`,
    risks: "",
    confidence: deriveConceptConfidence(item.score),
    status: "draft",
    sourceItemIds: [item.id],
    evidenceItems: [item],
    createdAt: timestamp,
    updatedAt: timestamp,
  });
}

export function normalizeConceptDraft(
  concept: SignalConcept,
  updates: Partial<
    Pick<
      SignalConcept,
      "title" | "targetUser" | "problem" | "opportunity" | "evidenceSummary" | "risks" | "confidence" | "status"
    >
  >
): SignalConcept {
  return signalConceptSchema.parse({
    ...concept,
    ...updates,
    updatedAt: new Date().toISOString(),
  });
}

