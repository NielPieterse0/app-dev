import { orderConcepts, type SignalConceptRepository } from "./concept-repository";
import { signalConceptsSchema, type SignalConcept } from "../schemas/concept.schema";

const storageKey = "signal.concepts";

function getStorage(storageOverride?: Storage) {
  if (storageOverride) {
    return storageOverride;
  }

  if (typeof window !== "undefined" && window.localStorage) {
    return window.localStorage;
  }

  return undefined;
}

export function createLocalConceptRepository(storageOverride?: Storage): SignalConceptRepository {
  let memoryConcepts: SignalConcept[] = [];

  return {
    async list() {
      const storage = getStorage(storageOverride);
      const raw = storage?.getItem(storageKey);

      if (!raw) {
        return orderConcepts(memoryConcepts);
      }

      memoryConcepts = orderConcepts(signalConceptsSchema.parse(JSON.parse(raw)));
      return memoryConcepts;
    },
    async save(concept) {
      const concepts = await this.list();
      const nextConcepts = orderConcepts([
        concept,
        ...concepts.filter((existingConcept) => existingConcept.id !== concept.id),
      ]);

      memoryConcepts = nextConcepts;
      const storage = getStorage(storageOverride);
      storage?.setItem(storageKey, JSON.stringify(nextConcepts));

      return concept;
    },
  };
}
