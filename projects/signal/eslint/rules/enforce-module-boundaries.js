import path from "node:path";

const MESSAGE_ID = "moduleBoundary";
const MODULE_SEGMENT = "/src/modules/";
const MODULE_ALIAS = "@/modules/";

function normalizePath(filePath) {
  return filePath.replace(/\\/g, "/");
}

function getModuleInfo(filePath) {
  const normalizedPath = normalizePath(filePath);
  const moduleIndex = normalizedPath.lastIndexOf(MODULE_SEGMENT);

  if (moduleIndex === -1) {
    return null;
  }

  const modulePath = normalizedPath.slice(moduleIndex + MODULE_SEGMENT.length);
  const [moduleName, ...segments] = modulePath.split("/").filter(Boolean);

  if (!moduleName) {
    return null;
  }

  return {
    moduleName,
    segments,
  };
}

function getImportInfo(source, importerPath) {
  if (source.startsWith(MODULE_ALIAS)) {
    const [moduleName, ...segments] = source.slice(MODULE_ALIAS.length).split("/").filter(Boolean);

    if (!moduleName) {
      return null;
    }

    return {
      kind: "alias",
      moduleName,
      isDeep: segments.length > 0,
    };
  }

  if (!source.startsWith(".")) {
    return null;
  }

  const resolvedPath = normalizePath(path.resolve(path.dirname(importerPath), source));
  const moduleIndex = resolvedPath.lastIndexOf(MODULE_SEGMENT);

  if (moduleIndex === -1) {
    return null;
  }

  const modulePath = resolvedPath.slice(moduleIndex + MODULE_SEGMENT.length);
  const [moduleName, ...segments] = modulePath.split("/").filter(Boolean);

  if (!moduleName) {
    return null;
  }

  return {
    kind: "relative",
    moduleName,
    isDeep: segments.length > 0,
  };
}

function reportBoundaryViolation(context, node, moduleName) {
  context.report({
    node,
    messageId: MESSAGE_ID,
    data: { moduleName },
  });
}

export default {
  meta: {
    type: "problem",
    docs: {
      description: "enforce module public API boundaries",
    },
    schema: [],
    messages: {
      [MESSAGE_ID]: "Import from the module public API (`@/modules/{{moduleName}}`) instead of another module’s internal files.",
    },
  },
  create(context) {
    const filename = context.filename ?? context.getFilename();

    if (!path.isAbsolute(filename)) {
      return {};
    }

    const importerModule = getModuleInfo(filename);

    return {
      ImportDeclaration(node) {
        const source = node.source.value;

        if (typeof source !== "string") {
          return;
        }

        const importInfo = getImportInfo(source, filename);

        if (!importInfo) {
          return;
        }

        if (importInfo.kind === "alias") {
          if (importerModule?.moduleName === importInfo.moduleName) {
            return;
          }

          if (importInfo.isDeep) {
            reportBoundaryViolation(context, node, importInfo.moduleName);
          }

          return;
        }

        if (importerModule?.moduleName === importInfo.moduleName) {
          return;
        }

        reportBoundaryViolation(context, node, importInfo.moduleName);
      },
    };
  },
};
