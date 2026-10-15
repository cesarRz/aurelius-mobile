import type { DrawingDocument, DrawingStroke } from "./entities";

const EMPTY: DrawingDocument = { version: 1, strokes: [] };

export function parseDrawingDocument(raw: string): DrawingDocument {
  if (!raw.trim()) {
    return { ...EMPTY, strokes: [] };
  }
  try {
    const parsed = JSON.parse(raw) as DrawingDocument;
    if (parsed?.version === 1 && Array.isArray(parsed.strokes)) {
      return parsed;
    }
  } catch {
    /* legacy PencilKit binary — start fresh on RN */
  }
  return { ...EMPTY, strokes: [] };
}

export function serializeDrawingDocument(doc: DrawingDocument): string {
  return JSON.stringify(doc);
}

export function emptyDrawingPayload(): string {
  return serializeDrawingDocument(EMPTY);
}

export function appendStroke(raw: string, stroke: DrawingStroke): string {
  const doc = parseDrawingDocument(raw);
  doc.strokes.push(stroke);
  return serializeDrawingDocument(doc);
}
