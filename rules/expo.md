---
paths:
  - "**/app.config.{ts,js}"
  - "**/app.json"
  - "**/eas.json"
  - "**/app/**/_layout.{ts,tsx}"
  - "**/app/**/+*.{ts,tsx}"
  - "**/*.{ios,android,native}.{ts,tsx}"
  - "**/metro.config.{js,ts}"
  - "**/plugins/**/*.{ts,js}"
---

# Expo and React Native

- Long lists use `FlashList`, never `FlatList` or `ScrollView` with mapped children. `estimatedItemSize` is set from a measurement, not guessed.
- Images go through `expo-image` with explicit dimensions and a `contentFit`. Never the core `Image`.
- Secrets and tokens live in `expo-secure-store`. `AsyncStorage` and MMKV are for non-sensitive state only.
- MMKV is for hot synchronous reads (settings, flags, small caches). Anything larger or relational is not storage for MMKV.
- Animation runs on the UI thread: Reanimated worklets and Gesture Handler. Never `Animated` from core, never JS-thread timers driving layout.
- Safe areas come from `react-native-safe-area-context` hooks or `SafeAreaView` from that package, never hardcoded insets or the core `SafeAreaView`.
- Platform differences go in `.ios.tsx` / `.android.tsx` files, not `Platform.OS` branches in JSX, unless the branch is one attribute.
- Environment comes from `app.config.ts`, exposed through `expo-constants`. Never `process.env` at runtime, never secrets in `extra`.
- Native modules are added through the Expo Modules API or a config plugin, never by editing `ios/` or `android/` directly under CNG.
- Routing is file-based through Expo Router. Layouts own navigation state; screens do not import the navigator.
- BLE, sensors, and other native streams are subscribed in one place and unsubscribed on cleanup; a listener that survives unmount is a bug.
- Nothing on the JS thread blocks a frame: heavy parsing, chart transforms, and crypto go to a worklet, a worker, or native.
- `expo-updates` runtime version policy and EAS build profiles are never changed as part of a feature ticket.
