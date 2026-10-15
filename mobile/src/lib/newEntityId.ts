import { v4 as uuidv4 } from "uuid";

import type { EntityId } from "../domain/entities";

/** UUID v4 for entity IDs — works in React Native where `crypto` is not global. */
export function newEntityId(): EntityId {
  return uuidv4();
}
