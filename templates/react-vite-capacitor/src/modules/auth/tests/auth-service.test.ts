import { beforeEach, describe, expect, test, vi } from "vitest";
import { signInWithEmailOtp, signOut } from "../services/auth-service";

const { signInWithOtp, signOutMock } = vi.hoisted(() => ({
  signInWithOtp: vi.fn(),
  signOutMock: vi.fn(),
}));

vi.mock("../../../lib/supabase", () => ({
  supabase: {
    auth: {
      signInWithOtp,
      signOut: signOutMock,
    },
  },
}));

describe("auth-service", () => {
  beforeEach(() => {
    signInWithOtp.mockReset();
    signOutMock.mockReset();
    signInWithOtp.mockResolvedValue({ data: {}, error: null });
    signOutMock.mockResolvedValue({ error: null });
  });

  test("signInWithEmailOtp uses the browser origin as the redirect target", async () => {
    await signInWithEmailOtp("person@example.com");

    expect(signInWithOtp).toHaveBeenCalledWith({
      email: "person@example.com",
      options: {
        emailRedirectTo: window.location.origin,
      },
    });
  });

  test("signOut delegates to supabase auth signOut", async () => {
    await signOut();

    expect(signOutMock).toHaveBeenCalledTimes(1);
  });
});
