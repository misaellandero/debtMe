# debtMe Task Log

Keep this concise. Record outcomes and decisions, not full chat transcripts.

## 2026-07-08 (b)
- Request: group What's New features by version (welcome sheet shows only the current release; Settings shows full history), rewrite this release's features in user language (no technical items), localize, and bump the version for a release.
- Files changed: `Shared/Models/Features/Feature.swift`, `Shared/Views/WhatsNew/FeaturesList.swift`, `Shared/Views/WhatsNew/WellcomeView.swift`, `Shared/Views/WhatsNew/WhatsNewView.swift`, `Shared/Localizable.xcstrings`, `debtMe.xcodeproj/project.pbxproj`.
- Decisions:
  - New `FeatureVersion` model; `whatsNewFeatures.versions` ordered newest-first ("1.2", "1.1", "1.0"); `latest` drives the welcome sheet, `FeaturesList(showAllVersions: true)` drives Settings with "Version %@" section headers.
  - Removed `newOnThisVersion` flag and the technical "Localization Cleanup" entry.
  - 1.2 features: Redesigned Widgets, Choose Your Widget Range, Services and Contacts Widgets, Services Summary, Smarter Icon Search (all es/ja localized).
  - Version bump: MARKETING_VERSION 1.1.2 → 1.2.0, CURRENT_PROJECT_VERSION 20260610 → 20260708 (iOS, macOS, widgets; visionOS left at 1.0).
- Verification: iOS + macOS Debug builds OK; simulator launch in Spanish shows "debtMe 1.2.0" welcome sheet with only the 1.2 features, localized.
- Follow-ups: archive/upload for release; visually check Settings → What's New history grouping.

## 2026-07-08
- Request: widget improvements (configurable date range via intents, service images/contact photos, ES localization, services-only and contacts-only widgets, "payment in n days" rows) plus app fixes (services balance summary like contacts, icon-only cancel in image picker on iOS, advanced/AI SF Symbol search, broken image-grid scroll on iOS).
- Files changed: `Widgets/DebtMeWidgets.swift`, `Shared/Views/Services/ServicesList.swift`, `Shared/Views/UIElements/Images/ImagePickerView.swift`, `Shared/Views/UIElements/Layout/AdaptiveGrid.swift`, `Shared/Localizable.xcstrings`.
- Decisions:
  - Widgets use `AppIntentConfiguration` with a shared `DebtWidgetRangeIntent` (7/14/30/60 days). New widget kinds: `ServicesPaymentsWidget`, `ContactsPaymentsWidget` reuse `UpcomingPaymentsProvider` with a source filter.
  - Widget images are thumbnailed (ImageIO, ~240px PNG) before being stored in timeline entries.
  - SF Symbol search reads the system `CoreGlyphs` search index with a curated fallback list; optional Apple Intelligence suggestions via FoundationModels (`sfSymbolSmartSearch` AppStorage toggle, only shown when the model is available).
  - `AdaptiveGrid` no longer wraps content in `GeometryReader` (it collapsed inside `ScrollView`, breaking scrolling); width is measured with a zero-height probe.
  - `Localizable.xcstrings` must be serialized with Foundation `JSONSerialization` `[.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]` to match Xcode's format (keeps diffs additive).
- Verification: `xcodebuild` Debug build succeeded for iOS Simulator and macOS; app launched on iPhone 17 Pro simulator with `-AppleLanguages (es)` and rendered Spanish UI. Not verified visually: widget gallery rendering, intent configuration UI, picker scroll feel on device.
- Follow-ups: visually check the new widgets and the SF Symbol search on a device; consider showing service `color` as widget icon background fallback.

## 2026-06-26
- Generated Claude/context handoff files.
- Added `.ai/` documentation structure for project continuity.

## Template
- Date:
- Request:
- Files changed:
- Decisions:
- Verification:
- Follow-ups:
