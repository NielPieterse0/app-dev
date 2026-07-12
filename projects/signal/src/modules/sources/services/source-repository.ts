import { isSupabaseConfigured } from "../../../lib/env";
import { getSupabaseClient } from "../../../lib/supabase";
import { type NormalizedSourceItem, type SourceKind } from "../schemas/source-item.schema";
import { createLocalSourceItemRepository } from "./local-source-item-repository";
import { createSupabaseSourceItemRepository } from "./supabase-source-item-repository";
import {
  type PersistedSourceFeed,
  type SourceItemsBackend,
  type SourceItemRepository,
} from "./source-item-repository";
import { fetchGithubSourceItems } from "./github-source-adapter";
import { fetchHackerNewsSourceItems } from "./hacker-news-source-adapter";

export type SourceItemFilters = {
  enabledSources?: SourceKind[];
  includeKeywords?: string[];
};

export type SourceFeedData = PersistedSourceFeed & {
  backend: SourceItemsBackend;
  degradedReason: string | null;
};

export type LiveSourceAdapterMap = Partial<Record<SourceKind, () => Promise<NormalizedSourceItem[]>>>;

function keywordMatches(item: NormalizedSourceItem, includeKeywords: string[]) {
  if (!includeKeywords.length) {
    return true;
  }

  return includeKeywords.every((keyword) => item.keywords.includes(keyword));
}

function applyFilters(items: NormalizedSourceItem[], filters: SourceItemFilters = {}) {
  const enabledSources = filters.enabledSources?.length ? filters.enabledSources : undefined;
  const includeKeywords = filters.includeKeywords ?? [];

  return items.filter((item) => {
    const sourceMatches = enabledSources ? enabledSources.includes(item.source) : true;
    return sourceMatches && keywordMatches(item, includeKeywords);
  });
}

async function loadSourceFeed(
  filters: SourceItemFilters,
  supabaseConfigured: boolean,
  primaryRepository: SourceItemRepository,
  fallbackRepository: SourceItemRepository
): Promise<SourceFeedData> {
  if (!supabaseConfigured) {
    const feed = await fallbackRepository.get();
    return {
      ...feed,
      backend: "local-fallback",
      degradedReason: null,
      items: applyFilters(feed.items, filters),
    };
  }

  try {
    const feed = await primaryRepository.get();
    return {
      ...feed,
      backend: "supabase",
      degradedReason: null,
      items: applyFilters(feed.items, filters),
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to reach Supabase.";
    const feed = await fallbackRepository.get();

    return {
      ...feed,
      backend: "local-fallback",
      degradedReason: message,
      items: applyFilters(feed.items, filters),
    };
  }
}

async function fetchLiveSourceItems(
  enabledSources: SourceKind[],
  adapters: LiveSourceAdapterMap = {}
) {
  const adapterBySource: Record<SourceKind, () => Promise<NormalizedSourceItem[]>> = {
    github: adapters.github ?? (() => fetchGithubSourceItems()),
    hacker_news: adapters.hacker_news ?? (() => fetchHackerNewsSourceItems()),
  };

  const batches = await Promise.all(enabledSources.map((source) => adapterBySource[source]()));
  return batches.flat();
}

export async function listSourceItems(
  filters: SourceItemFilters = {},
  options: {
    fallbackRepository?: SourceItemRepository;
    primaryRepository?: SourceItemRepository;
    supabaseConfigured?: boolean;
  } = {}
) {
  const fallbackRepository =
    options.fallbackRepository ?? createLocalSourceItemRepository();
  const supabaseConfigured = options.supabaseConfigured ?? isSupabaseConfigured();
  const primaryRepository =
    options.primaryRepository ??
    (supabaseConfigured
      ? createSupabaseSourceItemRepository(getSupabaseClient())
      : fallbackRepository);

  return loadSourceFeed(filters, supabaseConfigured, primaryRepository, fallbackRepository);
}

export async function refreshSourceItems(
  enabledSources: SourceKind[],
  options: {
    adapters?: LiveSourceAdapterMap;
    fallbackRepository?: SourceItemRepository;
    primaryRepository?: SourceItemRepository;
    supabaseConfigured?: boolean;
  } = {}
) {
  const fallbackRepository =
    options.fallbackRepository ?? createLocalSourceItemRepository();
  const supabaseConfigured = options.supabaseConfigured ?? isSupabaseConfigured();
  const primaryRepository =
    options.primaryRepository ??
    (supabaseConfigured
      ? createSupabaseSourceItemRepository(getSupabaseClient())
      : fallbackRepository);
  const refreshedAt = new Date().toISOString();
  const items = await fetchLiveSourceItems(enabledSources, options.adapters);

  if (!supabaseConfigured) {
    const feed = await fallbackRepository.replaceAll(items, refreshedAt);
    return {
      ...feed,
      backend: "local-fallback" as const,
      degradedReason: null,
    };
  }

  try {
    const feed = await primaryRepository.replaceAll(items, refreshedAt);
    return {
      ...feed,
      backend: "supabase" as const,
      degradedReason: null,
    };
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Failed to persist live source items.";
    const feed = await fallbackRepository.replaceAll(items, refreshedAt);

    return {
      ...feed,
      backend: "local-fallback" as const,
      degradedReason: message,
    };
  }
}
