import path from "node:path";
import { fileURLToPath } from "node:url";
import { ESLint } from "eslint";
import { describe, expect, it } from "vitest";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const fixtureRoot = path.join(projectRoot, "tests", "fixtures", "eslint-module-boundaries");

async function lintFixture(relativePath) {
  const eslint = new ESLint({
    cwd: projectRoot,
    ignore: false,
    overrideConfigFile: path.join(projectRoot, "eslint.config.js"),
    warnIgnored: false,
  });

  const [result] = await eslint.lintFiles([path.join(fixtureRoot, relativePath)]);
  return result;
}

describe("module boundary lint rule", () => {
  it("allows module barrel imports from outside modules", async () => {
    const result = await lintFixture(path.join("src", "app", "valid-outside-module.ts"));

    expect(result.messages).toHaveLength(0);
  }, 15000);

  it("rejects deep imports from outside modules", async () => {
    const result = await lintFixture(path.join("src", "app", "invalid-outside-module.ts"));

    expect(result.messages).toEqual([
      expect.objectContaining({
        ruleId: "app-dev/enforce-module-boundaries",
        message:
          "Import from the module public API (`@/modules/dashboard`) instead of another module’s internal files.",
      }),
    ]);
  });

  it("rejects relative cross-module imports from inside another module", async () => {
    const result = await lintFixture(path.join("src", "modules", "settings", "invalid-cross-module.ts"));

    expect(result.messages).toEqual([
      expect.objectContaining({
        ruleId: "app-dev/enforce-module-boundaries",
        message:
          "Import from the module public API (`@/modules/dashboard`) instead of another module’s internal files.",
      }),
    ]);
  });
});
