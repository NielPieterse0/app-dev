import { redirect } from "react-router-dom";
import { isSupabaseConfigured } from "../../../lib/env";
import { supabase } from "../../../lib/supabase";

export async function requireAuthSession() {
  if (!isSupabaseConfigured()) {
    throw redirect("/settings");
  }

  const { data, error } = await supabase.auth.getSession();

  if (error) {
    throw error;
  }

  if (!data.session) {
    throw redirect("/settings");
  }

  return data.session;
}
