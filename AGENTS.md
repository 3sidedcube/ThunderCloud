# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## Branching and PRs

PRs target the active `release/*` branch, never `master`. Automation that defaults to the
repo's default branch will open a `master`-targeted PR — check the base before relying on a
tool-created PR, and close any that targets `master`.

## Content requests and header scoping

`ContentController` exposes an optional injectable header provider for content requests. When
no provider is set, requests go through `RequestController` exactly as they always have; when
one is set they run on `ContentRequestSession` instead. Both paths must stay behaviourally
equivalent, and this framework is shared across apps — keep it generic, with no app-specific
or hardcoded host and header names. The allowed-host decision belongs to the injected
provider, which is asked about each new target url.

Sharp edge: background `URLSession` tasks follow redirects automatically and never call
`willPerformHTTPRedirection`, and `downloadPackage` defaults to `inBackground: true`. Any
per-redirect logic must therefore be applied by pre-resolving the chain on a default session
before handing the final url to the background transfer — a test that forces
`inBackground: false` will not catch the gap.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
