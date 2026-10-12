# Agent Instructions

## Repo Boundary Alert

Before editing files, running repo-specific commands, or giving a final implementation summary, verify that the user's latest request belongs to the current working repository. Use signals such as app/product names, paths, module names, feature names, open errors, and recently mentioned repos.

If the request appears to target a different repository or app than the current working directory, alert the user explicitly before making changes. State the current repo, the likely target repo, and that you are switching only after verifying the local path.

If the correct repo cannot be inferred confidently, stop and ask which repository to use. Do not silently apply changes to the current repo when repo ownership is ambiguous.

- The app base language is English. All new user-facing strings added to Swift, SwiftUI views, string catalogs, previews, and UI helper components must be written in English first.
- Do not add Spanish user-facing literals to the main codebase. Spanish should be provided through localization files only.
- When modifying UI, scan nearby new or changed strings and convert any accidental Spanish base strings to English.
- Before modifying SwiftUI views, sheets, navigation, buttons, or reusable UI elements, follow `Docs/STYLE_GUIDE.md`.
- Keep buttons consistent by using or extending shared UI elements in `Shared/Views/UIElements/Buttons` instead of adding one-off button styling.
- Main app views should use native large navigation titles that collapse while scrolling when the platform supports it.
- Add/edit sheets should use a navigation container with a clear close/cancel action on the left, a confirmation/action button on the top right, and a prominent bottom confirmation action when the sheet commits data.
- The app icon source of truth is the Icon Composer file at `icon.icon`. Do not recreate, replace, or restore the legacy `Shared/Assets.xcassets/AppIcon.appiconset` flow unless explicitly requested.

<!-- BOTMONITOR_REPORTING_BEGIN -->
## BotMonitor Reporting

This repository reports agent work to BotMonitor through GitHub issues. When Codex starts, advances, blocks, or finishes a task, keep the related issue current.

Required workflow:
- Before implementation, find or create a GitHub issue for the task.
- Add label `agent:codex` and `status:in-progress` while actively working.
- Add label `owner:misael` when the task belongs to Misael or requires his final decision.
- Add a short progress comment when a meaningful milestone is reached.
- If the task includes images, screenshots, App Store copy, or other context, keep those paths/text in the issue body or latest progress comment under a `Context` section.
- If user input is required, add label `status:needs-intervention`, remove `status:in-progress`, and comment with the exact decision or asset needed.
- When complete, comment with changed files and verification, then close the issue or label it `status:done`.

Preferred commands:
```sh
gh issue list --state open --limit 30
gh issue create --title "<task>" --body "<scope, plan, acceptance>" --label "agent:codex,status:in-progress"
gh issue comment <number> --body "<progress update>"
gh issue edit <number> --add-label "status:needs-intervention" --remove-label "status:in-progress"
gh issue close <number> --comment "<summary and tests>"
```

Keep updates concise and factual. Do not include secrets, tokens, private keys, or credential file contents in issues.
<!-- BOTMONITOR_REPORTING_END -->