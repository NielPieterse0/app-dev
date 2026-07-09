import fs from "node:fs";
import path from "node:path";

const workspaceRoot = process.cwd();
const projectsRoot = path.join(workspaceRoot, "projects");

function toDisplayName(slug) {
  return slug
    .split("-")
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

const project = fs.existsSync(projectsRoot)
  ? fs
      .readdirSync(projectsRoot, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => {
        const relativePath = path.posix.join("projects", entry.name);
        return {
          name: toDisplayName(entry.name),
          path: relativePath,
          hasPackageJson: fs.existsSync(path.join(workspaceRoot, relativePath, "package.json")),
        };
      })
      .filter((entry) => entry.hasPackageJson)
      .map(({ hasPackageJson, ...entry }) => entry)
  : [];

process.stdout.write(JSON.stringify({ project }));
