import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { requireSupabaseEnv } from "./env";

let supabaseClient: SupabaseClient | undefined;

export function getSupabaseClient() {
  if (!supabaseClient) {
    const configuredEnv = requireSupabaseEnv(import.meta.env as Record<string, string | undefined>);

    supabaseClient = createClient(
      configuredEnv.VITE_SUPABASE_URL,
      configuredEnv.VITE_SUPABASE_PUBLISHABLE_KEY
    );
  }

  return supabaseClient;
}

export const supabase = new Proxy({} as SupabaseClient, {
  get(_target, property, receiver) {
    const client = getSupabaseClient();
    const value = Reflect.get(client as object, property, receiver);

    return typeof value === "function" ? value.bind(client) : value;
  },
});
