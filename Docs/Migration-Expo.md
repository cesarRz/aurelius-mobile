# Aurelius → Expo (React Native)

The SwiftUI app remains in `Aurelius/` for reference. The active cross-platform client lives in `mobile/`.

## Stack

| Concern | Swift (before) | Expo (now) |
| --- | --- | --- |
| UI | SwiftUI | **HeroUI Native** + Uniwind (Tailwind v4) |
| Navigation | TabView + NavigationStack | **Expo Router** (tabs + stack) |
| State | `@Observable WorkspaceStore` | **Zustand** (`useWorkspaceStore`) |
| Block documents | `BlockEditorRow` + `@FocusState` | Custom block rows + `TextInput` focus map |
| Drawing | **PencilKit** (`PKDrawing` Data) | **@shopify/react-native-skia** + JSON strokes |
| Inbox voice | **Speech** + AVAudioEngine | **expo-speech-recognition** |
| Audio meters | AVAudioEngine tap | `volumechange` events from speech module |

## Pain points & library choices

### 1. Block editor (Notion-style blocks)

- **Library:** none (intentionally)—markdown shortcuts and per-block `TextInput` mirror Swift logic in `interpretBlockSyntax`.
- **Why not TipTap / TenTap:** heavier WebView or native bridge; Swift app already uses lightweight blocks, not full rich text.
- **Code:** `mobile/src/components/editor/BlockDocumentEditor.tsx`, `blockSyntax.ts`

### 2. Pencil / drawing blocks

- **Library:** [@shopify/react-native-skia](https://shopify.github.io/react-native-skia/) (Expo-compatible, GPU paths).
- **Persistence:** JSON `{ version: 1, strokes: [...] }` in `DocumentBlock.drawingData` (string). **PKDrawing blobs are not migrated.**
- **Code:** `mobile/src/components/editor/SkiaDrawingCanvas.tsx`, `drawingDocument.ts`

### 3. Inbox dictation

- **Library:** [expo-speech-recognition](https://github.com/jamsch/expo-speech-recognition) — unified iOS/Android speech APIs, partial results, volume metering.
- **Code:** `mobile/src/services/useInboxDictation.ts`

## Run

Use a **development build** (not Expo Go) for drawing blocks and inbox dictation—those modules need native code from this project.

```bash
cd mobile
npm install
npx expo run:ios      # or: npx expo run:android
npm run start         # Metro (after native app is installed)
npm run typecheck
npm test
```

Deep links use the `aurelius://` URL scheme (`app.json` → `expo.scheme`).

## Screen parity (current)

- Tabs: Agenda, Planning, Docs, More
- Modals: area, initiative, outcome, task, milestone forms
- Document / note block editors, outcome workspace, inbox capture
- Agenda filters, grouping, and long-press task actions (Swift parity)

## Next steps

- Persist workspace (SQLite / WatermelonDB / Convex sync)
- Port Swift test coverage to Vitest (agenda, inbox, store mutations)
- iPad split view and remaining Swift-only UX polish
- Optional: `@10play/tentap-editor` if you need collaborative rich text later
