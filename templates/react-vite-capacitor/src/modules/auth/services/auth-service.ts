import { supabase } from "../../../lib/supabase";

export async function signInWithEmailOtp(email: string) {
  return supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: window.location.origin,
    },
  });
}

export async function signOut() {
  return supabase.auth.signOut();
}
