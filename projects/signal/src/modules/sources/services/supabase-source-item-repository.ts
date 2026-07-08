import type { SupabaseClient } from "@supabase/supabase-js";
import {
  createPersistedSourceItemRows,
  mapPersistedRowsToSourceFeed,
  type SourceItemRepository,
} from "./source-item-repository";

export function createSupabaseSourceItemRepository(client: SupabaseClient): SourceItemRepository {
  const get = async () => {
    const itemResponse = await client
      .from("source_items")
      .select(
        "id, source, external_id, title, summary, url, author, published_at, collected_at, engagement_count, score, keywords"
      )
      .order("score", { ascending: false })
      .order("published_at", { ascending: false });

    if (itemResponse.error) {
      throw new Error(`Failed to load source items: ${itemResponse.error.message}`);
    }

    const feedStateResponse = await client
      .from("signal_feed_state")
      .select("feed_key, last_refreshed_at")
      .eq("feed_key", "default");

    if (feedStateResponse.error) {
      throw new Error(`Failed to load feed state: ${feedStateResponse.error.message}`);
    }

    return mapPersistedRowsToSourceFeed(
      itemResponse.data ?? [],
      feedStateResponse.data ?? []
    );
  };

  return {
    get,
    async replaceAll(items, refreshedAt) {
      const response = await client.rpc("replace_signal_source_items", {
        items_payload: createPersistedSourceItemRows(items),
        refreshed_at_input: refreshedAt ?? new Date().toISOString(),
      });

      if (response.error) {
        throw new Error(`Failed to replace source items: ${response.error.message}`);
      }

      return get();
    },
  };
}
