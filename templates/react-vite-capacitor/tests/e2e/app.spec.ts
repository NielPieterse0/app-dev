import { expect, test } from "@playwright/test";

test("loads the starter app across required responsive widths", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Workspace starter" })).toBeVisible();
  await expect(page.getByRole("navigation", { name: "Primary" })).toBeVisible();
  await expect(page.getByRole("columnheader", { name: "Module" })).toBeVisible();
  await expect(page.getByRole("button", { name: "New module" })).toBeVisible();

  await page.getByRole("link", { name: "Settings" }).click();
  await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Notifications" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Save settings" })).toBeVisible();

  const hasHorizontalOverflow = await page.evaluate(() => {
    const { documentElement } = document;
    return documentElement.scrollWidth > documentElement.clientWidth;
  });

  expect(hasHorizontalOverflow).toBe(false);
});
