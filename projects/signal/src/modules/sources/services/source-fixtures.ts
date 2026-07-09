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
