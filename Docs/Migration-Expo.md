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

```bash
cd mobile
npm run start    # Metro
npm run ios
npm run android
npm run typecheck
npm test
```

## Next steps

- Persist workspace (SQLite / WatermelonDB / Convex sync)
- Port remaining Swift screens (forms, outcome workspace, iPad split view)
- Optional: `@10play/tentap-editor` if you need collaborative rich text later
