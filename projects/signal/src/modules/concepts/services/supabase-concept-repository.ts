import type { SupabaseClient } from "@supabase/supabase-js";
import {
  createConceptRow,
  mapConceptRows,
  mapConceptRpcPayload,
  type SignalConceptRepository,
} from "./concept-repository";

export function createSupabaseConceptRepository(client: SupabaseClient): SignalConceptRepository {
  return {
    async list() {
      const response = await client
        .from("signal_concepts")
        .select(
          "id, title, target_user, problem, opportunity, evidence_summary, risks, confidence, status, source_item_ids, evidence_items, created_at, updated_at"
        )
        .order("updated_at", { ascending: false });

      if (response.error) {
        throw new Error(`Failed to load concepts: ${response.error.message}`);
      }

      return mapConceptRows(response.data ?? []);
    },
    async save(concept) {
      const response = await client.rpc("upsert_signal_concept", {
        concept_payload: createConceptRow(concept),
      });

      if (response.error) {
        throw new Error(`Failed to save concept: ${response.error.message}`);
      }

      return mapConceptRpcPayload(response.data);
    },
  };
}

