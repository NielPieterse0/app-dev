import {
  normalizedSourceItemsSchema,
  normalizeKeywordInput,
  type NormalizedSourceItem,
  type SourceKind,
} from "../schemas/source-item.schema";
import { defaultSourceSettings } from "./source-settings-repository";
import { getGithubFixtures, getHackerNewsFixtures } from "./source-fixtures";
import {
  normalizeGithubRepository,
  normalizeHackerNewsItem,
  orderRankedItems,
} from "./source-normalizer";

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
