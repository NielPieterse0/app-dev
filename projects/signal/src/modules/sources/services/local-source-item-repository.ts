import { type PersistedSourceFeed, type SourceItemRepository } from "./source-item-repository";

const storageKey = "signal.source-feed";

function getStorage(storageOverride?: Storage) {
  if (storageOverride) {
    return storageOverride;
  }

  if (typeof window !== "undefined" && window.localStorage) {
    return window.localStorage;
  }

  return undefined;
}

export function createLocalSourceItemRepository(storageOverride?: Storage): SourceItemRepository {
  let memoryFeed: PersistedSourceFeed = {
    items: [],
    lastRefreshedAt: null,
  };

  return {
    async get() {
      const storage = getStorage(storageOverride);
      const raw = storage?.getItem(storageKey);

      if (!raw) {
        return memoryFeed;
      }

      memoryFeed = JSON.parse(raw) as PersistedSourceFeed;
      return memoryFeed;
    },
    async replaceAll(items, refreshedAt) {
      memoryFeed = {
        items,
        lastRefreshedAt: refreshedAt ?? new Date().toISOString(),
      };

      const storage = getStorage(storageOverride);
      storage?.setItem(storageKey, JSON.stringify(memoryFeed));

      return memoryFeed;
    },
  };
}
