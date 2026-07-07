import { describe, expect, test } from "vitest";
import { homeCopy } from "../app/page";

describe("Next starter", () => {
  test("exports starter page copy", () => {
    expect(homeCopy.title).toBe("Next app ready");
  });
});
