# debtMe Current State

Last updated: 2026-07-08

## Status
Preparing release 1.2.0 (build 20260708). Widget overhaul, image-picker improvements, and version-grouped What's New implemented and building on iOS/macOS.

## What Works
- Widgets: Debt Flow, People Debts, Upcoming Payments, plus new Services-only and Contacts-only widgets. Date range (7/14/30/60 days) configurable per-widget via App Intents; rows show service images / contact photos and "Payment in n days" (localized ES/JA).
- Image picker: cancel buttons are icon-only (xmark) on iOS/visionOS; SF Symbol sheet has search with grid results (system CoreGlyphs index + curated fallback) and optional Apple Intelligence suggestions; image/brand grids scroll correctly (AdaptiveGrid GeometryReader fix).
- Services list: "All" summary now mirrors Contacts (Income / Expenses / Balance large blocks + service count).

## Known Issues
- Widget gallery/intent UI and on-device scroll feel not yet visually verified (build + simulator launch only).

## In Progress
- Nothing pending from the 2026-07-08 batch.

## Next Steps
- Visual pass over the new widgets on device/simulator widget gallery.
- Confirm FoundationModels suggestions quality on a device with Apple Intelligence.

## Verification Notes
- 2026-07-08: `xcodebuild -scheme 'debtMe (iOS)' -destination 'generic/platform=iOS Simulator' build` → OK; same for `debtMe (macOS)` and `DebtMeWidgets`. App launched in Spanish on iPhone 17 Pro simulator (welcome sheet + tabs localized). Use `DEVELOPER_DIR=/Applications/Xcode-27.0.0-Beta.2.app/Contents/Developer` (xcode-select points at CommandLineTools).
