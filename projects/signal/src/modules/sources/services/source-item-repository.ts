import { z } from "zod";
import {
  normalizedSourceItemSchema,
  normalizedSourceItemsSchema,
  type NormalizedSourceItem,
} from "../schemas/source-item.schema";
import { orderRankedItems } from "./source-normalizer";

export type SourceItemsBackend = "supabase" | "local-fallback";

export type PersistedSourceFeed = {
  items: NormalizedSourceItem[];
  lastRefreshedAt: string | null;
};

export type SourceItemRepository = {
  get(): Promise<PersistedSourceFeed>;
  replaceAll(items: NormalizedSourceItem[], refreshedAt?: string): Promise<PersistedSourceFeed>;
};

export const sourceItemsQueryKey = ["source-items"] as const;

const persistedSourceItemRowSchema = z.object({
  author: z.string().min(1),
  collected_at: z.string().datetime(),
  engagement_count: z.number().int().nonnegative(),
  external_id: z.string().min(1),
  id: z.string().min(1),
  keywords: z.array(z.string()).default([]),
  published_at: z.string().datetime(),
  score: z.number().nonnegative(),
  source: z.enum(["github", "hacker_news"]),
  summary: z.string().min(1),
  title: z.string().min(1),
  url: z.string().url(),
});

const persistedFeedStateRowSchema = z.object({
  feed_key: z.literal("default"),
  last_refreshed_at: z.string().datetime().nullable().optional(),
});

const persistedSourceItemsRowsSchema = z.array(persistedSourceItemRowSchema);
const persistedFeedStateRowsSchema = z.array(persistedFeedStateRowSchema).max(1);

export function mapPersistedRowsToSourceFeed(
  itemRows: unknown,
  feedStateRows: unknown
): PersistedSourceFeed {
  const parsedRows = persistedSourceItemsRowsSchema.parse(itemRows);
  const parsedFeedStateRows = persistedFeedStateRowsSchema.parse(feedStateRows);
  const items = normalizedSourceItemsSchema.parse(
    parsedRows.map((row) =>
      normalizedSourceItemSchema.parse({
        author: row.author,
        collectedAt: row.collected_at,
        engagementCount: row.engagement_count,
        externalId: row.external_id,
        id: row.id,
        keywords: row.keywords,
        publishedAt: row.published_at,
        score: row.score,
        source: row.source,
        summary: row.summary,
        title: row.title,
        url: row.url,
      })
    )
  );

  return {
    items: orderRankedItems(items),
    lastRefreshedAt: parsedFeedStateRows[0]?.last_refreshed_at ?? null,
  };
}

export function createPersistedSourceItemRows(
  items: NormalizedSourceItem[]
): Array<{
  author: string;
  collected_at: string;
  engagement_count: number;
  external_id: string;
  id: string;
  keywords: string[];
  published_at: string;
  score: number;
  source: "github" | "hacker_news";
  summary: string;
  title: string;
  url: string;
}> {
  const parsedItems = normalizedSourceItemsSchema.parse(items);

  return parsedItems.map((item) => ({
    author: item.author,
    collected_at: item.collectedAt,
    engagement_count: item.engagementCount,
    external_id: item.externalId,
    id: item.id,
    keywords: item.keywords,
    published_at: item.publishedAt,
    score: item.score,
    source: item.source,
    summary: item.summary,
    title: item.title,
    url: item.url,
  }));
}
