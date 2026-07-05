import { expect, test } from "@playwright/test";

test("loads the starter app", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "Workspace starter" })).toBeVisible();
  await expect(page.getByRole("navigation", { name: "Primary" })).toBeVisible();
});
