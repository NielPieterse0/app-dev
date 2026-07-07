import { describe, expect, test } from "vitest";
import { dashboardModuleSchema } from "../schemas/dashboard-module.schema";

describe("dashboardModuleSchema", () => {
  test("parses a valid module row", () => {
    const module = dashboardModuleSchema.parse({
      id: "planning",
      name: "Planning",
      status: "ready",
    });

    expect(module.status).toBe("ready");
  });

  test("fails when status is invalid", () => {
    expect(() =>
      dashboardModuleSchema.parse({
        id: "planning",
        name: "Planning",
        status: "unknown",
      })
    ).toThrow();
  });

  test("supports ready draft blocked status values", () => {
    const statuses = ["ready", "draft", "blocked"] as const;

    statuses.forEach((status) => {
      expect(
        dashboardModuleSchema.parse({
          id: status,
          name: status,
          status,
        }).status
      ).toBe(status);
    });
  });
});
