import { useEffect, useState } from "react";
import type { Session } from "@supabase/supabase-js";
import { isSupabaseConfigured } from "../../../lib/env";
import { supabase } from "../../../lib/supabase";

type AuthSessionState = {
  session: Session | null;
  isLoading: boolean;
  error: Error | null;
};

export function useAuthSession(): AuthSessionState {
  const [state, setState] = useState<AuthSessionState>({
    session: null,
    isLoading: true,
    error: null,
  });

  useEffect(() => {
    if (!isSupabaseConfigured()) {
      setState({
        session: null,
        isLoading: false,
        error: null,
      });

      return undefined;
    }

    let isMounted = true;

    void supabase.auth
      .getSession()
      .then(({ data, error }) => {
        if (!isMounted) {
          return;
        }

        setState({
          session: data.session,
          isLoading: false,
          error: error ? new Error(error.message) : null,
        });
      })
      .catch((error: unknown) => {
        if (!isMounted) {
          return;
        }

        setState({
          session: null,
          isLoading: false,
          error: error instanceof Error ? error : new Error("Failed to load auth session."),
        });
      });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!isMounted) {
        return;
      }

      setState({
        session,
        isLoading: false,
        error: null,
      });
    });

    return () => {
      isMounted = false;
      subscription.unsubscribe();
    };
  }, []);

  return state;
}
