---
id: development-proxy-base-path
title: Development proxy base path
category: decision
status: active
tags: [development, flutter, web]
created: "2026-09-01T02:13:41"
updated: "2026-09-01T02:14:01"
---

<!-- compiled_truth -->
## Decision

Flutter web development is accessed at `https://code-home.manifold.rocks/proxy/8080/` while the Flutter web server still binds to `0.0.0.0:8080`.

The manifold proxy strips `/proxy/<port>/` before forwarding requests. Because Flutter 3.41.6 dev serving derives its server-side base path from a literal `<base>` element in `web/index.html`, the source file must not contain a literal `<base href="/proxy/8080/">`; doing so would make the Flutter server expect prefixed request paths that the proxy has already removed.

Instead, `kalias/web/index.html` injects a `<base>` tag at runtime by detecting `/proxy/<port>/` in `window.location.pathname`, falling back to Flutter's normal `$FLUTTER_BASE_HREF` substitution for direct localhost and build flows. VS Code launch configs pass `--web-launch-url=https://code-home.manifold.rocks/proxy/8080/` in `toolArgs` so the browser opens at the proxy URL.


## Timeline

- time: 2026-09-01T02:13:41
  kind: decision
  summary: "Created this page: Development proxy base path"
  source: User request on 2026-09-01
  affects: [development-proxy-base-path]

- time: 2026-09-01T02:14:01
  kind: decision
  summary: Recorded manifold proxy base-path handling for Flutter web dev
  source: Implemented in VS Code launch configs and kalias/web/index.html on 2026-09-01
  affects: [development-proxy-base-path]
