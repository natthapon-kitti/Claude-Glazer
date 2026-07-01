# Claude Glazer

A tiny macOS menu bar app that shows your real Claude Code usage against the
5-hour and weekly rate limits — no login, no API keys, no network calls of
its own.

## How it works

Claude Glazer doesn't talk to Anthropic's servers. Claude Code CLI already
does, and already knows your real `rate_limits` (used percentage + reset
time) for the 5-hour and 7-day windows. A `statusLine` hook captures that
data to a local cache file every time Claude Code renders its status line,
and Claude Glazer just reads it.

```
Claude Code CLI (authenticated) → statusLine hook → ~/.claude/usage_status_cache.json → Claude Glazer
```

Because it only reads a file written by *your* logged-in CLI sessions, it's
inherently per-account with zero auth code: it always shows whoever's usage
wrote that file.

**Caveat:** the cache only updates while an active `claude` session is
rendering its status line. During quiet periods the menu bar shows the
last-known values, not a live poll.

## Setup

1. Install [`jq`](https://jqlang.github.io/jq/) if you don't have it:
   `brew install jq`
2. Copy the hook script and make it executable:
   ```sh
   mkdir -p ~/.claude/hooks
   cp Scripts/usage_statusline.sh ~/.claude/hooks/usage_statusline.sh
   chmod +x ~/.claude/hooks/usage_statusline.sh
   ```
3. Point Claude Code's `statusLine` at it in `~/.claude/settings.json`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash \"$HOME/.claude/hooks/usage_statusline.sh\""
     }
   }
   ```
   (Merge this into your existing `settings.json` rather than replacing it.)
4. Start a Claude Code session so the status line renders at least once —
   that's what populates `~/.claude/usage_status_cache.json`.

## Building

- Requires Xcode with the macOS SDK (not just Command Line Tools) and
  macOS 13+ (for the `SMAppService` login-item API).
- Open `ClaudeUsageMenuBar.xcodeproj` and run the `ClaudeUsageMenuBar`
  scheme.
- The app is sandbox-off by design, since it reads a file under `~/.claude`.

## Features

- Menu bar icon shows both the 5-hour and weekly percentage at a glance.
- Dropdown shows each window's percentage, a gauge bar that ramps
  clay → amber → red as you approach the cap, and its reset time.
- Runs as a background agent — no Dock icon, no Cmd+Tab entry.
- Optional "Open at Login" toggle in the dropdown.

## Project layout

```
App/        App entry point (MenuBarExtra scene, menu bar label)
Models/     Usage data model
Services/   UsageMonitor — reads the cache file
Views/      MenuView — the dropdown UI
Scripts/    usage_statusline.sh — the statusLine hook (lives in ~/.claude when installed)
```
