# Aurelius Mobile (Expo)

React Native client for Aurelius, scaffolded with **HeroUI Native** and **Expo Router**.

See [../Docs/Migration-Expo.md](../Docs/Migration-Expo.md) for Swift → RN mapping and pain-point libraries (Skia, speech recognition, block editor).

## Prerequisites

- Node.js 20+
- Xcode (iOS) and/or Android Studio (Android)

**Expo Go is not enough** for full feature testing: `@shopify/react-native-skia` and `expo-speech-recognition` require a dev build of this app.

## Commands

```bash
npm install
npx expo run:ios       # first-time native build + install
npx expo run:android
npm run start          # Metro (use with the dev build above)
npm run typecheck
npm run lint
npm test
```

URL scheme for deep links: `aurelius://` (see `app.json`).
