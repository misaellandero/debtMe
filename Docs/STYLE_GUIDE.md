# DebtMe Style Guide

This document is the **source of truth** for the visual language of DebtMe across iOS, macOS, and visionOS.

If something in the UI deviates, prefer updating the UI to match this guide (or update this guide intentionally as part of a design change).

## Typography (Apple system fonts)

DebtMe uses Apple’s system fonts:
- **SF Pro** (default system font) for most text.
- **SF Pro Rounded** for *brand accents* only (titles and primary UI labels), to keep the app friendly without harming readability.

### Rules

- Avoid `.weight(.black)` for general UI. It creates inconsistent density and hurts legibility in dark mode.
- Use **semantic** fonts (`.title2`, `.headline`, `.body`, `.caption`) and only apply weights when needed.
- Use `.foregroundStyle(.primary/.secondary)` (not hard-coded colors) so text adapts to light/dark.
- Prefer **one weight step** stronger than default for emphasis (`.semibold`), and reserve `.bold` for key totals only.

### Font scale

| Token | SwiftUI | Use for |
|---|---|---|
| `brandTitle` | `.system(.title2, design: .rounded).weight(.bold)` | App name header, key screen titles |
| `brandHeadline` | `.system(.headline, design: .rounded).weight(.semibold)` | Toolbar/menu label buttons, primary action labels |
| `title` | `.title2.weight(.bold)` | Section hero totals (balances) |
| `headline` | `.headline.weight(.semibold)` | Section headers |
| `body` | `.body` | Default content text |
| `caption` | `.caption` | Helper labels, metadata |

### Code source of truth

Typography tokens live in code here:
- `Shared/App/Extensions/ImageExtension.swift` (see `AppTypography` and the `View` helpers).

Use:
- `.appBrandTitle()`
- `.appToolbarLabel()`
- `.appHeadline()` / `.appTitle()`

## Icons

- Use SF Symbols (`systemImage`) for UI controls and toolbar items.
- Keep icon weight consistent with the text (avoid extra-bold icon+text combos).
- Prefer clear, standard symbols:
  - Calendar/List toggle: `calendar` / `list.bullet`
  - Add: `plus.circle.fill`
  - Edit: `square.and.pencil`
  - Delete/remove: `trash`
  - Cancel/close: `xmark`

## Navigation & Screen Titles

Every primary screen must have a clear title that follows native platform behavior.

- Use SwiftUI navigation titles for screen-level titles instead of custom floating labels.
- On iOS and iPadOS, prefer large navigation titles for main screens so the title starts large and collapses naturally while scrolling:
  - `.navigationTitle("Home")`
  - `.navigationBarTitleDisplayMode(.large)`
- Secondary/detail screens may use `.inline` when the content would otherwise feel too tall.
- Do not manually recreate collapsing title behavior unless the native navigation title cannot support the layout.
- Avoid placing the screen title inside scroll content when it should belong to the navigation bar.
- If a screen scrolls, the scrollable content should sit inside the navigation container so large-title collapse works.

## Color & materials

- Text: use `.primary` / `.secondary` styles, not explicit `.white`/`.black`.
- Background fills: use subtle system-aware fills like `Color.secondary.opacity(0.08...0.12)` or materials (`.thinMaterial`) for floating UI.
- Accent color: use `.accentColor` for primary emphasis; don’t introduce random hard-coded accent colors.

### Accent buttons
- Primary actions should use `.buttonStyle(.borderedProminent)` with `.tint(.accentColor)`.
- Secondary “pill” controls (filters, small toggles) can use `.thinMaterial` in a `Capsule()` with `AppTypography.brandHeadline`.

## Buttons & Actions

Buttons must be visually consistent across the app. Prefer shared button components and button styles from `Shared/Views/UIElements/Buttons` before adding new ad-hoc button styling.

### Button hierarchy

| Role | Use for | Style |
|---|---|---|
| Primary | Save, Add, Continue, Confirm | `.buttonStyle(.borderedProminent)` + `.tint(.accentColor)` |
| Secondary | Edit, filters, non-destructive options | `.buttonStyle(.bordered)` or app shared secondary style |
| Destructive | Delete, Remove, Cancel destructive flows | `.tint(.red)` with clear `trash` or destructive symbol |
| Toolbar | Top navigation actions | `ToolbarAddButton` or a shared toolbar action view |

### Rules

- Do not create one-off button colors, padding, corner radius, or font treatment when a shared style exists.
- Icon + text buttons should use `Label` with `.labelStyle(.titleAndIcon)` when space allows.
- Icon-only buttons must use standard SF Symbols and should have an accessibility label.
- Primary confirmation actions must appear in two places for sheets/forms:
  - Top-right navigation/toolbar action.
  - Bottom prominent full-width or clearly emphasized action.
- Cancel/close must be clearly visible and placed top-left in navigation for sheets/forms.
- Avoid ambiguous actions like two buttons doing the same thing (`Apply` and `Done`). Keep one confirmation action.
- On iOS, large form action buttons should stack vertically or fill available width when horizontal space is limited.
- Matching button widths should be handled with layout, shared styles, or fixed/max frames. Avoid invisible characters as spacing unless there is no platform-safe alternative.

### Shared components

Use or extend these before adding new button code:

- `ToolbarAddButton`
- `ButtonLabelAdd`
- `ButtonLabelContinue`
- `ButtonLabelReset`
- `ButtonLabelPayAll`

## Layout & spacing

- Standard horizontal padding: **16** (cards), **20** (floating bottom bar on iOS).
- Corner radius:
  - Calendar day cells: `calendarCellCornerRadius` (currently `12`)
  - Calendar card container: `calendarCardCornerRadius` (currently `18`)
- Avoid “magic” sizes inside leaf views; prefer shared tokens when the same shape repeats across screens.

## Platform expectations

### macOS
- Use `NavigationSplitView` + inspector for detail where appropriate.
- Avoid modal sheets for list selection flows unless the action is truly modal.
- Sheets must use a fixed, comfortable default size. If content is taller than the fixed size, make the content scroll instead of shrinking the sheet.
- Sheets should be wrapped in a navigation container when they have cancel/confirm actions.
- Sheet controls should follow the same placement as iOS:
  - Close/cancel on the left.
  - Confirm/action on the right.
  - Prominent bottom action when the form has a primary commit action.

### iOS / visionOS
- Use `NavigationStack` per tab.
- Keep primary controls reachable; prefer bottom safe-area inset for the period navigator.
- Main views should use large navigation titles.
- Modal forms and sheets should use navigation toolbar actions plus a bottom prominent action when saving/creating data.

## Sheets & Forms

All add/edit sheets should follow the same structure:

```swift
NavigationStack {
    ScrollView {
        // Form content
    }
    .navigationTitle("Edit")
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
            }
            .tint(.red)
        }

        ToolbarItem(placement: .confirmationAction) {
            ToolbarAddButton(edition: true) {
                save()
            }
        }
    }
    .safeAreaInset(edge: .bottom) {
        Button {
            save()
        } label: {
            Label("Save", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentColor)
        .padding()
    }
}
```

### Sheet rules

- A sheet must always provide an obvious close button.
- A sheet that commits data must provide a top-right confirmation action and a bottom prominent confirmation action.
- Keep the top confirmation action compact; keep the bottom confirmation action prominent.
- Use English base strings for sheet titles and buttons.
- Do not hide the only save/create action inside scroll content.
- Do not let long forms push the bottom action offscreen; scroll the form content instead.

## Definition of done (visual consistency)

A screen is considered consistent when:
- Titles, toolbar labels, and actions use tokens from **Typography**.
- Text adapts in light/dark mode (no hard-coded text colors).
- Repeated components (calendar cells, cards, floating bars) share the same corner radii and spacing rules.
- Main screens use native large navigation titles where appropriate.
- Sheets include consistent close, top-right action, and bottom prominent action placement.
- Buttons use shared styles/components instead of one-off styling.
