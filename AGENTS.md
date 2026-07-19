# Agent Instructions

- The app base language is English. All new user-facing strings added to Swift, SwiftUI views, string catalogs, previews, and UI helper components must be written in English first.
- Do not add Spanish user-facing literals to the main codebase. Spanish should be provided through localization files only.
- When modifying UI, scan nearby new or changed strings and convert any accidental Spanish base strings to English.
- Before modifying SwiftUI views, sheets, navigation, buttons, or reusable UI elements, follow `Docs/STYLE_GUIDE.md`.
- Keep buttons consistent by using or extending shared UI elements in `Shared/Views/UIElements/Buttons` instead of adding one-off button styling.
- Main app views should use native large navigation titles that collapse while scrolling when the platform supports it.
- Add/edit sheets should use a navigation container with a clear close/cancel action on the left, a confirmation/action button on the top right, and a prominent bottom confirmation action when the sheet commits data.
