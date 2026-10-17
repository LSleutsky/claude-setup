# React Native and Expo

The repo's existing way of doing each of these wins; these apply where it has none. They assume the New Architecture: React Native 0.82 or newer, Expo SDK 55 or newer. Check `package.json` first; on an older version FlashList 1, Reanimated 3, and Gesture Handler 2 APIs apply, and you say so.

## Structure

- Expo Router: the root `_layout.tsx` owns providers, fonts, and splash; each `_layout` owns one navigator; nest navigators only when the UI needs it. Screens are thin and never import the navigator.
- Feature folders as in the React rules: `features/<name>/` holds a feature's components, hooks, api calls, and types. Route files in `app/` compose them.
- `useLocalSearchParams`, not `useGlobalSearchParams` (it re-renders every background screen). Never name a param `screen`, `params`, `initial`, or `state`.
- `Stack.Protected` and `Tabs.Protected` gate navigation only; authorization is checked on the server.
- `<Link href>` for navigation, `router.*` only for conditional logic, typed routes on, never string-built paths.
- Platform differences live in `.ios.tsx`, `.android.tsx`, `.native.tsx`, `.web.tsx` files or `Platform.select`; never `Platform.OS` branches in JSX beyond one attribute.

## Components

- `Pressable` for every touch target, never `TouchableOpacity` or `TouchableWithoutFeedback`. Targets are at least 44 by 44 points on iOS and 48 by 48 dp on Android, or get `hitSlop` to reach it.
- `expo-image` with explicit dimensions and `contentFit`, never the core `Image`. `recyclingKey` inside recycled lists.
- Safe areas from `react-native-safe-area-context` (`useSafeAreaInsets`, or its `SafeAreaView` with `edges`), never the deprecated core `SafeAreaView` or hardcoded insets.
- Keyboard through `react-native-keyboard-controller` (`KeyboardAwareScrollView`, `KeyboardStickyView`, `KeyboardToolbar`); the core `KeyboardAvoidingView` only where the repo already uses it.
- `useWindowDimensions`, never `Dimensions.get` inside a component.
- Removed or deprecated in core, never in new code: `ImageBackground` (a `View` with an absolute `expo-image`), `InteractionManager` (`requestIdleCallback`), core `SafeAreaView`, `AsyncStorage`, `Clipboard`, `PushNotificationIOS`, `InputAccessoryView`, `StatusBar` `backgroundColor`.
- Styles in `StyleSheet.create` outside the component, or the repo's styling library. No style objects built per render.
- `allowFontScaling` stays on; `maxFontSizeMultiplier` caps growth only where layout would break.

## Lists

- `FlashList` v2 for any list that can grow: no size estimates, `keyExtractor` always, `getItemType` for mixed rows, `useRecyclingState` for per-item state, no `key` prop inside `renderItem`. `maintainVisibleContentPosition` is on by default; disable it when rows reorder.
- Legend List for chat and bidirectional infinite scroll, without `inverted` tricks.
- `FlatList` only inside an existing list the task does not replace; then `keyExtractor`, memoized rows, `getItemLayout` for fixed heights. `removeClippedSubviews` can hide content on iOS.
- Never a `ScrollView` with mapped children beyond a screen of rows.

## Animation and gestures

- Reanimated 4 on the UI thread: worklets and shared values for gesture, scroll, and orchestrated animations; the CSS-style API (`animationName`, transitions) for state-driven ones. Never core `Animated` for new animation, never JS timers driving layout.
- `useAnimatedStyle` only on Animated components; never mutate a shared value inside it. Static styles stay in `StyleSheet.create` and merge as `[styles.box, animatedStyle]`.
- Back to React through `scheduleOnRN` (formerly `runOnJS`); the function it calls is defined in React scope.
- Layout animation builders are created outside the component or in `useMemo`.
- Gesture Handler 3: hook gestures (`usePanGesture`, `useTapGesture`) composed with `useSimultaneousGestures` and friends; `GestureHandlerRootView` sits at the app root.
- `enableFreeze()` from `react-native-screens` at startup so blurred screens stop rendering.

## Data and storage

- Server state through the repo's query library, same rules as React. Client state in the repo's store.
- Secrets and tokens in `expo-secure-store` only, values under 2 KB. Never in MMKV, AsyncStorage, or `EXPO_PUBLIC_` variables.
- MMKV for hot synchronous reads (settings, flags, small caches). `expo-sqlite` for anything relational or large. AsyncStorage is unencrypted and slow; do not add it.
- Native streams (BLE, sensors, location) subscribe in one place and unsubscribe on cleanup; a listener that outlives its screen is a bug.

## Config and native

- `EXPO_PUBLIC_*` values ship in plain text in the bundle, referenced as the literal `process.env.EXPO_PUBLIC_X`, never destructured. Everything else comes from `app.config.ts` through `expo-constants`; never import the config file from app code; no secrets in it.
- Under CNG, `ios/` and `android/` are generated and never edited; native changes go through config plugins and `expo-build-properties`. Native modules use the Expo Modules API; Nitro or Turbo only for C++ or a measured hot path, and the plan says why.
- `expo-updates` settings, the `runtimeVersion` policy, and EAS profiles never change inside a feature ticket. A native change needs a new build, not an update.
- Development builds (`expo-dev-client`), not Expo Go, for any library with native code.

## Performance

- 16 ms per frame. Nothing heavy on the JS thread during interaction: parsing, chart transforms, and crypto move to a worklet, a worker, or native.
- Measure on a release build with React Native DevTools, never on dev. `console.log` is stripped from production bundles (`babel-plugin-transform-remove-console`).
- Screens load lazily, `inlineRequires` stays on, no module-level side effects. Check bundle growth with Expo Atlas when adding a dependency.
- React Compiler on (`experiments.reactCompiler`); with it, no manual `memo` or `useMemo`.
- Uncontrolled `TextInput` for fast typing; controlled only when every keystroke must drive state.

## Accessibility

- Every touchable has `accessibilityLabel` (or `aria-label`), a `role`, and `accessibilityState` or `aria-*` for selected, checked, disabled, expanded. Decorative views get `accessibilityElementsHidden` and `importantForAccessibility="no"`.
- A row is one element (`accessible`) so the screen reader reads it once.
- Status changes announce through `AccessibilityInfo.announceForAccessibility` or `accessibilityLiveRegion`; after a screen change focus moves with `AccessibilityInfo.sendAccessibilityEvent(ref, 'focus')`.
- Respect `isReduceMotionEnabled`. Contrast 4.5:1 for text, 3:1 for UI.
- Verify with VoiceOver and TalkBack on the changed screens before calling a UI phase done.

## Testing

- React Native Testing Library: `*ByRole` with a name, `*ByLabelText`, then `*ByText`; `userEvent` with fake timers for press; no snapshots.
- End-to-end through Maestro on a development build, with `testID` as the selector.
