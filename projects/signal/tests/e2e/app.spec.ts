import { expect, test } from "@playwright/test";

test("loads the signal dashboard across required responsive widths", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Trend scout" })).toBeVisible();
  await expect(page.getByRole("navigation", { name: "Primary" })).toBeVisible();
  await expect(page.getByRole("columnheader", { name: "Signal" })).toBeVisible();
  await expect(page.getByRole("button", { name: "GitHub" })).toBeVisible();

  await page.getByRole("link", { name: "Settings" }).click();
  await expect(page.getByRole("heading", { name: "Signal settings" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Keywords" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Enabled GitHub" })).toBeVisible();

  await page.getByRole("link", { name: "Keywords" }).click();
  await expect(page.getByRole("heading", { name: "Keyword pressure" })).toBeVisible();
  await expect(page.getByRole("textbox", { name: "Keyword filters" })).toBeVisible();

  const hasHorizontalOverflow = await page.evaluate(() => {
    const { documentElement } = document;
    return documentElement.scrollWidth > documentElement.clientWidth;
  });

  expect(hasHorizontalOverflow).toBe(false);
});
