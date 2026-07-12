import { z } from "zod";
import { normalizedSourceItemSchema, type NormalizedSourceItem } from "../schemas/source-item.schema";
import { calculateTrendScore, orderRankedItems } from "./source-normalizer";

const hackerNewsItemSchema = z.object({
  by: z.string().default("unknown"),
  dead: z.boolean().optional().default(false),
  deleted: z.boolean().optional().default(false),
  descendants: z.number().int().nonnegative().optional().default(0),
  id: z.number().int().nonnegative(),
  score: z.number().int().nonnegative().optional().default(0),
  time: z.number().int().nonnegative(),
  title: z.string().optional(),
  type: z.literal("story"),
  url: z.string().url().optional(),
});

function extractKeywords(title: string) {
  return Array.from(
    new Set(
      title
        .split(/[^a-z0-9+.#-]+/i)
        .map((value) => value.trim().toLowerCase())
        .filter((value) => value.length >= 4)
    )
  );
}

export async function fetchHackerNewsSourceItems(
  fetcher: typeof fetch = fetch,
  now = new Date()
): Promise<NormalizedSourceItem[]> {
  const topStoriesResponse = await fetcher(
    "https://hacker-news.firebaseio.com/v0/topstories.json"
  );

  if (!topStoriesResponse.ok) {
    throw new Error(`Hacker News refresh failed with status ${topStoriesResponse.status}.`);
  }

  const topStories = z.array(z.number().int().nonnegative()).parse(
    await topStoriesResponse.json()
  );

  const itemResponses = await Promise.all(
    topStories.slice(0, 12).map(async (itemId) => {
      const response = await fetcher(
        `https://hacker-news.firebaseio.com/v0/item/${itemId}.json`
      );

      if (!response.ok) {
        throw new Error(`Hacker News item ${itemId} failed with status ${response.status}.`);
      }

      return response.json();
    })
  );

  const items = itemResponses
    .map((item) => hackerNewsItemSchema.parse(item))
    .filter((item) => !item.dead && !item.deleted && item.title && item.url);

  return orderRankedItems(
    items.map((item) => {
      const publishedAt = new Date(item.time * 1000).toISOString();
      const engagementCount = item.score + item.descendants;

      return normalizedSourceItemSchema.parse({
        author: item.by,
        collectedAt: now.toISOString(),
        engagementCount,
        externalId: String(item.id),
        id: `hacker_news:${item.id}`,
        keywords: extractKeywords(item.title ?? ""),
        publishedAt,
        score: calculateTrendScore(engagementCount, publishedAt, now),
        source: "hacker_news",
        summary: `HN discussion by ${item.by} with ${item.descendants} comments and ${item.score} points.`,
        title: item.title,
        url: item.url,
      });
    })
  );
}
