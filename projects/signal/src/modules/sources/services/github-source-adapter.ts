import { z } from "zod";
import { normalizedSourceItemSchema, type NormalizedSourceItem } from "../schemas/source-item.schema";
import { calculateTrendScore, orderRankedItems } from "./source-normalizer";

const githubRepositorySchema = z.object({
  description: z.string().nullable().optional(),
  full_name: z.string().min(1),
  html_url: z.string().url(),
  id: z.number().int().nonnegative(),
  language: z.string().nullable().optional(),
  name: z.string().min(1),
  owner: z.object({
    login: z.string().min(1),
  }),
  pushed_at: z.string().datetime(),
  stargazers_count: z.number().int().nonnegative(),
  topics: z.array(z.string()).optional().default([]),
});

const githubSearchResponseSchema = z.object({
  items: z.array(githubRepositorySchema),
});

function extractKeywords(repository: z.infer<typeof githubRepositorySchema>) {
  return Array.from(
    new Set(
      [
        ...(repository.topics ?? []),
        repository.language ?? "",
        ...repository.name.split(/[-_/]/g),
        ...(repository.description ?? "").split(/[^a-z0-9+.#-]+/i),
      ]
        .map((value) => value.trim().toLowerCase())
        .filter((value) => value.length >= 3)
    )
  );
}

export async function fetchGithubSourceItems(
  fetcher: typeof fetch = fetch,
  now = new Date()
): Promise<NormalizedSourceItem[]> {
  const since = new Date(now);
  since.setUTCDate(since.getUTCDate() - 7);

  const url = new URL("https://api.github.com/search/repositories");
  url.searchParams.set(
    "q",
    `topic:ai pushed:>=${since.toISOString().slice(0, 10)} archived:false stars:>=20`
  );
  url.searchParams.set("sort", "updated");
  url.searchParams.set("order", "desc");
  url.searchParams.set("per_page", "8");

  const response = await fetcher(url.toString(), {
    headers: {
      Accept: "application/vnd.github+json",
      "X-GitHub-Api-Version": "2022-11-28",
    },
  });

  if (!response.ok) {
    throw new Error(`GitHub refresh failed with status ${response.status}.`);
  }

  const payload = githubSearchResponseSchema.parse(await response.json());

  return orderRankedItems(
    payload.items.map((repository) =>
      normalizedSourceItemSchema.parse({
        author: repository.owner.login,
        collectedAt: now.toISOString(),
        engagementCount: repository.stargazers_count,
        externalId: String(repository.id),
        id: `github:${repository.id}`,
        keywords: extractKeywords(repository),
        publishedAt: repository.pushed_at,
        score: calculateTrendScore(
          repository.stargazers_count,
          repository.pushed_at,
          now
        ),
        source: "github",
        summary:
          repository.description ??
          `${repository.full_name} is trending without a repository description.`,
        title: repository.full_name,
        url: repository.html_url,
      })
    )
  );
}
