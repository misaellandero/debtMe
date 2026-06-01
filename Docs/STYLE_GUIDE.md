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

## Color & materials

- Text: use `.primary` / `.secondary` styles, not explicit `.white`/`.black`.
- Background fills: use subtle system-aware fills like `Color.secondary.opacity(0.08...0.12)` or materials (`.thinMaterial`) for floating UI.
- Accent color: use `.accentColor` for primary emphasis; don’t introduce random hard-coded accent colors.

### Accent buttons
- Primary actions should use `.buttonStyle(.borderedProminent)` with `.tint(.accentColor)`.
- Secondary “pill” controls (filters, small toggles) can use `.thinMaterial` in a `Capsule()` with `AppTypography.brandHeadline`.

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

### iOS / visionOS
- Use `NavigationStack` per tab.
- Keep primary controls reachable; prefer bottom safe-area inset for the period navigator.

## Definition of done (visual consistency)

A screen is considered consistent when:
- Titles, toolbar labels, and actions use tokens from **Typography**.
- Text adapts in light/dark mode (no hard-coded text colors).
- Repeated components (calendar cells, cards, floating bars) share the same corner radii and spacing rules.
