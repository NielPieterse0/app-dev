import type { SignalConcept } from "../schemas/concept.schema";
import { sourceLabels } from "@/modules/sources";

export function buildConceptExportPayload(concept: SignalConcept) {
  return {
    id: concept.id,
    title: concept.title,
    targetUser: concept.targetUser,
    problem: concept.problem,
    opportunity: concept.opportunity,
    evidenceSummary: concept.evidenceSummary,
    risks: concept.risks,
    confidence: concept.confidence,
    status: concept.status,
    sourceItemIds: concept.sourceItemIds,
    evidenceItems: concept.evidenceItems.map((item) => ({
      id: item.id,
      source: item.source,
      sourceLabel: sourceLabels[item.source],
      title: item.title,
      url: item.url,
      author: item.author,
      score: item.score,
      engagementCount: item.engagementCount,
      publishedAt: item.publishedAt,
      keywords: item.keywords,
      summary: item.summary,
    })),
    createdAt: concept.createdAt,
    updatedAt: concept.updatedAt,
  };
}

export function buildConceptMarkdown(concept: SignalConcept) {
  const payload = buildConceptExportPayload(concept);
  const evidenceLines = payload.evidenceItems
    .map(
      (item) =>
        `- ${item.sourceLabel}: [${item.title}](${item.url}) | score ${item.score.toFixed(1)} | engagement ${item.engagementCount} | keywords ${item.keywords.join(", ")}`
    )
    .join("\n");

  return `# ${payload.title}

## Target User

${payload.targetUser || "TBD"}

## Problem

${payload.problem || "TBD"}

## Opportunity

${payload.opportunity || "TBD"}

## Evidence Summary

${payload.evidenceSummary || "TBD"}

## Risks

${payload.risks || "TBD"}

## Concept Status

- Status: ${payload.status}
- Confidence: ${payload.confidence}
- Source item ids: ${payload.sourceItemIds.join(", ")}

## Supporting Signals

${evidenceLines}
`;
}

