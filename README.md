# Premium Chat

A premium dark-themed AI chat interface built with Flutter and deployed as a static site on GitHub Pages.

**Live:** https://amraaai0000-coder.github.io/premium-chat/

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Build

```bash
flutter build web --release --base-href /premium-chat/ --no-web-resources-cdn
```

The compiled output is committed to `docs/`, which GitHub Pages serves.

## Layout

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | Whole app: chat screen, prompt chips, message bubbles, composer |
| `web/` | Web shell (`index.html`, `manifest.json`) |
| `docs/` | Compiled static site served by GitHub Pages |
