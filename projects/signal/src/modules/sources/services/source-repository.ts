import {
  normalizedSourceItemsSchema,
  normalizeKeywordInput,
  sourceSettingsSchema,
  type NormalizedSourceItem,
  type SourceKind,
  type SourceSettings,
} from "../schemas/source-item.schema";
import { getGithubFixtures, getHackerNewsFixtures } from "./source-fixtures";
import {
  normalizeGithubRepository,
  normalizeHackerNewsItem,
  orderRankedItems,
} from "./source-normalizer";

export const defaultSourceSettings: SourceSettings = sourceSettingsSchema.parse({
  enabledSources: ["github", "hacker_news"],
  includeKeywords: [],
});

export type SourceItemFilters = {
  enabledSources?: SourceKind[];
  includeKeywords?: string[];
};

function keywordMatches(item: NormalizedSourceItem, includeKeywords: string[]) {
  if (!includeKeywords.length) {
    return true;
  }

  return includeKeywords.every((keyword) => item.keywords.includes(keyword));
}

function getSeedSourceItems() {
  const githubItems = getGithubFixtures().map((repository) => normalizeGithubRepository(repository));
  const hackerNewsItems = getHackerNewsFixtures().map((item) => normalizeHackerNewsItem(item));

  return normalizedSourceItemsSchema.parse([...githubItems, ...hackerNewsItems]);
}

export async function listSourceItems(filters: SourceItemFilters = {}) {
  const enabledSources = filters.enabledSources?.length
    ? filters.enabledSources
    : defaultSourceSettings.enabledSources;
  const includeKeywords = normalizeKeywordInput((filters.includeKeywords ?? []).join(","));

  return orderRankedItems(
    getSeedSourceItems().filter((item) => {
      return enabledSources.includes(item.source) && keywordMatches(item, includeKeywords);
    })
  );
}

export async function listSourceSettings() {
  return sourceSettingsSchema.parse(defaultSourceSettings);
}
