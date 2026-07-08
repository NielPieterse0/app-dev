import {
  normalizedSourceItemSchema,
  normalizedSourceItemsSchema,
  type NormalizedSourceItem,
} from "../schemas/source-item.schema";
import type { GithubRepositoryFixture, HackerNewsFixture } from "./source-fixtures";

const RECENCY_WEIGHT = 28;
const ENGAGEMENT_WEIGHT = 0.12;

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function normalizeKeywords(keywords: string[]) {
  return Array.from(
    new Set(
      keywords
        .map((keyword) => keyword.trim().toLowerCase())
        .filter(Boolean)
    )
  );
}

export function calculateTrendScore(engagementCount: number, publishedAt: string, now = new Date()) {
  const publishedDate = new Date(publishedAt);
  const ageInHours = Math.max((now.getTime() - publishedDate.getTime()) / 36e5, 1);
  const recencyScore = clamp(RECENCY_WEIGHT - ageInHours * 0.18, 2, RECENCY_WEIGHT);
  const engagementScore = Math.sqrt(engagementCount) * ENGAGEMENT_WEIGHT * 10;

  return Number((recencyScore + engagementScore).toFixed(2));
}

export function normalizeGithubRepository(
  repository: GithubRepositoryFixture,
  now = new Date()
): NormalizedSourceItem {
  return normalizedSourceItemSchema.parse({
    id: `github:${repository.id}`,
    source: "github",
    externalId: repository.id,
    title: `${repository.owner}/${repository.name}`,
    summary: repository.description,
    url: repository.url,
    author: repository.owner,
    publishedAt: repository.pushedAt,
    collectedAt: now.toISOString(),
    engagementCount: repository.stars,
    score: calculateTrendScore(repository.stars, repository.pushedAt, now),
    keywords: normalizeKeywords(repository.topics),
  });
}

export function normalizeHackerNewsItem(item: HackerNewsFixture, now = new Date()): NormalizedSourceItem {
  return normalizedSourceItemSchema.parse({
    id: `hacker_news:${item.id}`,
    source: "hacker_news",
    externalId: item.id,
    title: item.title,
    summary: `HN discussion by ${item.author} with ${item.commentCount} comments and ${item.points} points.`,
    url: item.url,
    author: item.author,
    publishedAt: item.publishedAt,
    collectedAt: now.toISOString(),
    engagementCount: item.points + item.commentCount,
    score: calculateTrendScore(item.points + item.commentCount, item.publishedAt, now),
    keywords: normalizeKeywords(item.tags),
  });
}

export function orderRankedItems(items: NormalizedSourceItem[]) {
  return normalizedSourceItemsSchema.parse(
    [...items].sort((left, right) => {
      if (right.score !== left.score) {
        return right.score - left.score;
      }

      return new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime();
    })
  );
}

export function buildActivityPoints(items: NormalizedSourceItem[]) {
  const grouped = new Map<string, { label: string; github: number; hacker_news: number }>();

  items.forEach((item) => {
    const date = new Date(item.publishedAt);
    const label = date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
    const existing = grouped.get(label) ?? { label, github: 0, hacker_news: 0 };
    existing[item.source] += 1;
    grouped.set(label, existing);
  });

  return [...grouped.values()];
}
