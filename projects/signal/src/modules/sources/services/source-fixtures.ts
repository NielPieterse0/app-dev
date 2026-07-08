import type { SourceKind } from "../schemas/source-item.schema";

export type GithubRepositoryFixture = {
  id: string;
  name: string;
  owner: string;
  description: string;
  stars: number;
  url: string;
  pushedAt: string;
  topics: string[];
};

export type HackerNewsFixture = {
  id: string;
  title: string;
  author: string;
  points: number;
  commentCount: number;
  url: string;
  publishedAt: string;
  tags: string[];
};

function isoDaysAgo(daysAgo: number, hour = 9) {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - daysAgo);
  date.setUTCHours(hour, 0, 0, 0);
  return date.toISOString();
}

export function getGithubFixtures(): GithubRepositoryFixture[] {
  return [
    {
      id: "gh-react-compiler",
      name: "react-compiler",
      owner: "meta",
      description: "Compiler work that keeps pushing React ergonomics into production reality.",
      stars: 1280,
      url: "https://github.com/facebook/react",
      pushedAt: isoDaysAgo(1, 14),
      topics: ["react", "compiler", "frontend"],
    },
    {
      id: "gh-agent-runtime",
      name: "agent-runtime",
      owner: "open-operators",
      description: "Runtime patterns for orchestrating small agent workflows without overbuilding infra.",
      stars: 760,
      url: "https://github.com/example/agent-runtime",
      pushedAt: isoDaysAgo(2, 11),
      topics: ["agents", "automation", "developer-tools"],
    },
    {
      id: "gh-postgres-dx",
      name: "postgres-dx",
      owner: "db-lab",
      description: "Developer-experience helpers around schema diffs and query instrumentation.",
      stars: 420,
      url: "https://github.com/example/postgres-dx",
      pushedAt: isoDaysAgo(4, 8),
      topics: ["postgres", "observability", "backend"],
    },
  ];
}

export function getHackerNewsFixtures(): HackerNewsFixture[] {
  return [
    {
      id: "hn-context-engineering",
      title: "Show HN: Context engineering for product-scoped agents",
      author: "buildthread",
      points: 392,
      commentCount: 118,
      url: "https://news.ycombinator.com/item?id=10000001",
      publishedAt: isoDaysAgo(1, 7),
      tags: ["agents", "productivity", "ai-tools"],
    },
    {
      id: "hn-founder-research",
      title: "Ask HN: What research workflows actually produce startup ideas?",
      author: "makergrid",
      points: 214,
      commentCount: 73,
      url: "https://news.ycombinator.com/item?id=10000002",
      publishedAt: isoDaysAgo(3, 10),
      tags: ["startup", "research", "ideas"],
    },
    {
      id: "hn-supabase-growth",
      title: "Supabase at small scale: when free tier stops being enough",
      author: "dbsignal",
      points: 168,
      commentCount: 54,
      url: "https://news.ycombinator.com/item?id=10000003",
      publishedAt: isoDaysAgo(5, 12),
      tags: ["supabase", "founder-tools", "ops"],
    },
  ];
}

export const sourceLabels: Record<SourceKind, string> = {
  github: "GitHub",
  hacker_news: "Hacker News",
};
