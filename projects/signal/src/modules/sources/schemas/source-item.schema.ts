import { z } from "zod";

export const sourceKindSchema = z.enum(["github", "hacker_news"]);

const normalizedKeywordSchema = z.string().trim().min(1).transform((value) => value.toLowerCase());

export const normalizedSourceItemSchema = z.object({
  id: z.string().min(1),
  source: sourceKindSchema,
  externalId: z.string().min(1),
  title: z.string().min(1),
  summary: z.string().min(1),
  url: z.string().url(),
  author: z.string().min(1),
  publishedAt: z.string().datetime(),
  collectedAt: z.string().datetime(),
  engagementCount: z.number().int().nonnegative(),
  score: z.number().nonnegative(),
  keywords: z.array(normalizedKeywordSchema),
});

export const normalizedSourceItemsSchema = z.array(normalizedSourceItemSchema);

export const sourceSettingsSchema = z.object({
  enabledSources: z.array(sourceKindSchema).min(1),
  includeKeywords: z.array(normalizedKeywordSchema),
});

export type SourceKind = z.infer<typeof sourceKindSchema>;
export type NormalizedSourceItem = z.infer<typeof normalizedSourceItemSchema>;
export type SourceSettings = z.infer<typeof sourceSettingsSchema>;

export function normalizeKeywordInput(value: string) {
  const keywords = value
    .split(",")
    .map((entry) => entry.trim().toLowerCase())
    .filter(Boolean);

  return Array.from(new Set(keywords));
}
