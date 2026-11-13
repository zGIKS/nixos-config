---
name: go-ddd
description: Implement, audit, or refactor Go DDD bounded contexts with Gin at interfaces/rest, cohesive aggregate and feature packages, consumer-owned ports, context-owned adapters, explicit consistency and error contracts, safe event delivery, and process composition outside the domain. Keep unit tests beside code and integration/E2E under root test. Use for Go/Gin architecture and bounded-context work without imposing a database, ORM, configuration library, or full layered scaffold.
---

# Go DDD — Operational Workflow

Use this skill to implement a bounded-context feature, audit architectural boundaries, or refactor a Go/Gin backend. DDD models business meaning; it is not a directory checklist. Prefer a modular monolith until deployment requirements justify distribution. Do not invent aggregates for simple CRUD, or confuse CQS with a requirement for separate read/write stores.

Use an organization-approved stable Go release, standard `testing`/`httptest`, `errors`, and request context. Document HTTP contracts with OpenAPI 3.1; use structured `log/slog` and operationally justified OpenTelemetry at the appropriate boundaries. Preserve existing project contracts and treat dependency/toolchain upgrades as explicit changes, not incidental refactor steps.

## Authority and scope

This skill is the authoritative operational and architectural specification for Domain-Driven Design in Go with Gin. It defines package placement, dependency boundaries, persistence mapping, error contracts, and runtime lifecycle.

References below provide decisions and operational checks for each layer.

## Architectural references & evidence

- Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software* — Bounded Context and Shared Kernel patterns.
- [DDD Crew — Context Mapping patterns](https://virtualddd.com/ddd-crew/context-mapping/) — Shared Kernel and Anti-Corruption Layer.
- [Martin Fowler — Bounded Context](https://martinfowler.com/bliki/BoundedContext.html) — boundaries and model consistency.
- [Mark Seemann — Composition Root](https://blog.ploeh.dk/2011/07/28/CompositionRoot/) — centralized composition at the process boundary, modular composition per sub-application.
- [Kamil Grzybek — Modular Monolith with DDD](https://github.com/kgrzybek/modular-monolith-with-ddd) — lean host pattern calling module initialization; each module owns its composition root.
- [Al-Qora'n & Al-Said Ahmad (2025) — Modular monolith architecture in cloud environments](https://doi.org/10.3390/fi17110496) — systematic review of modular monolith trade-offs and structural governance.
- [Carvalho et al. (2025) — Towards a progressive scalability for modular monolith applications](https://doi.org/10.5220/0013327600003982) — G1 governance criterion: architectural boundaries verified automatically in build/test.
- [Özkan et al. (2025) — Domain-driven design in software development](https://doi.org/10.1016/j.jss.2024.112287) — systematic literature review of DDD in software development and bounded context boundaries.
- [Go Code Review Comments — Interfaces](https://go.dev/wiki/CodeReviewComments#interfaces) — "Go interfaces generally belong in the package that uses values of the interface type" and "Do not define interfaces before they are used".
- [Go 1.13 Errors — working with errors](https://go.dev/blog/go1.13-errors) — sentinel errors, `errors.Is`/`errors.As`, and `%w` wrapping.
- [The repository pattern in Go — threedots.tech](https://threedots.tech/post/repository-pattern-in-go/) — consumer-defined repository interfaces in Go.
- [Database transactions in Go with layered architecture — threedots.tech](https://threedots.tech/post/database-transactions-in-go/) — keeping transaction handles out of the logic layer.
- [Go and a Package Focused Design](https://blog.gopheracademy.com/advent-2016/go-and-package-focused-design/) — packages as the unit of cohesion and encapsulation.
- [Go Wiki — TableDrivenTests](https://go.dev/wiki/TableDrivenTests) — table-driven tests and named subtests.
- [Go — Organizing a Go module](https://go.dev/doc/modules/layout) — `internal/`, executable layout, and import boundaries.

### Pinned repository evidence & lessons

| Repository / evidence | Pattern observed | Architectural lesson |
|---|---|---|
| [sklinkert/go-ddd](https://github.com/sklinkert/go-ddd) | GORM to sqlc; PostgreSQL integration tests; manual wiring | Keep generated access in infrastructure; single-file wiring works for 1 context but does not scale to modular monoliths |
| [marcusolsson/goddd](https://github.com/marcusolsson/goddd) | Removal of Java-style interfaces and empty hierarchies | Avoid importing inheritance-style scaffolding into Go |
| [ThreeDotsLabs/wild-workouts-go-ddd-example](https://github.com/ThreeDotsLabs/wild-workouts-go-ddd-example) | Clean architecture and CQRS in Go; 100% technical common | Shared package is strictly technical; ports belong to consumers |
| [bxcodec/golang-ddd-modular-monolith-with-hexagonal](https://github.com/bxcodec/golang-ddd-modular-monolith-with-hexagonal) | Factory per module, but central `Config` struct with module keys | Anti-pattern: module autonomy is broken when module configuration is centralized in the host |
| [kamil5b/go-pste-monolith](https://github.com/kamil5b/go-pste-monolith) | Centralized `container.go` (415 lines) wiring all contexts | Anti-pattern: bootstrap becomes a God Package; context internals must remain publicly exported |
| [rizkydwicmt/vibe-ddd-golang](https://github.com/rizkydwicmt/vibe-ddd-golang) | Context-level `module.go` registering Gin routes and dependencies | Modular composition root per bounded context keeps boundaries intact |
| [kgrzybek/modular-monolith-with-ddd](https://github.com/kgrzybek/modular-monolith-with-ddd) | Lean host orchestrating bounded context module entry points via `Initialize` | Benchmark for composition: host manages runtime, modules manage their own dependencies |

## Non-negotiable working rules

1. **Respect the requested mode.** Audit-only means findings and a correction plan, not edits. Implementation/refactoring permission does not authorize unrelated API, schema, dependency, or tooling changes.
2. **Preserve contracts.** Inventory routes, methods, payloads, statuses, business rules, ownership, and persistence semantics before moving code. Separate intentional contract changes from architectural moves.
3. **Keep policy inward.** Domain contains business behavior; application coordinates use cases through consumed ports. Neither imports Gin, concrete adapters, configuration, or engine transaction handles.
4. **Use inbound interfaces deliberately.** `interfaces/rest/` owns REST resources and handlers; `interfaces/events/` owns incoming message adaptation. Publishers and outbound clients belong in infrastructure. Place ACLs by direction, not name.
5. **Organize by context and responsibility.** Keep aggregate concepts cohesive. Keep use-case input/result/handler together when useful; `resources/` and `transform/` are optional, not obligatory packages.
6. **Make failures and consistency explicit.** Match errors with `errors.Is`/`errors.As`, propagate request context, check commit results, and document callback retries. No unsafe external effects in retryable transactions or destructive event consumption before persistence succeeds.
7. **Keep composition modular and outside the model.** Each context owns its self-contained composition root (`module.go`) and scoped configuration (`Config`). A lean host (`cmd/api/` / `internal/bootstrap/`) owns process lifecycle, shared technical infrastructure, and module coordination without reaching into context internals. Shared packages require real compatible consumers and explicit ownership.
8. **Review growth, not just line count.** Review every hand-written Go file over 150 physical lines; split/move/merge/delete by responsibility or record a cohesion rationale. Never hand-edit generated output.
9. **Test continuously.** Unit tests stay beside code. Integration/E2E live under module-root `/test`, grouped by context and responsibility, and have explicit CI execution.
10. **Add only justified mechanisms.** No mandatory database, ORM, migration/configuration/DI library, event bus, outbox, interface pair, or empty layer. Existing useful organization need not be renamed merely to resemble examples.

## Execute one vertical slice

| Phase | Required work | Load when relevant |
|---|---|---|
| 1. Inspect | Read project instructions, module/workspace setup, imports, existing contracts, tests, and generated-code boundaries | [Architecture](references/architecture-and-structure.md) |
| 2. Specify | Name the behavior, owning context, invariants/preconditions, failure outcomes, authorization, and consistency guarantee | [Domain](references/domain-model.md), [errors](references/errors.md) |
| 3. Model | Implement/test only the values and transitions this behavior requires; test zero values and unchanged state after rejection | [Domain](references/domain-model.md), [testing](references/testing.md) |
| 4. Orchestrate | Define input/result and narrow consumed ports; implement the use case with real domain objects and boundary fakes | [Application](references/application-layer.md) |
| 5. Adapt | Implement mapping/reconstitution, concurrency, and actual atomicity; run real-engine contract tests | [Persistence](references/persistence.md) |
| 6. Expose | Add REST or inbound-message adaptation, safe error translation, or justified model translation | [REST/events](references/rest-api.md), [integration/ACL](references/context-integration.md) |
| 7. Compose | Wire dependencies and verify startup, shutdown, cancellation, and required telemetry | [Runtime](references/runtime-and-observability.md) |
| 8. Verify | Run applicable checks; review imports, oversized files, contract stability, and critical E2E behavior | [Testing](references/testing.md), [architecture](references/architecture-and-structure.md) |

Tests, error contracts, and observability accompany the slice; none is postponed to a final project phase. Load relevant references before making their decisions, not every reference for every task.

## Audit and refactor procedure

For an audit, produce:

1. A bounded-context/package/import map, including published APIs and cross-context data access.
2. Findings with severity, exact `path:line`, observed evidence, impact, and proposed correction. Distinguish verified defects, design trade-offs, and hypotheses requiring execution.
3. A file-action inventory: split, move, merge, delete, or retain, including a decision for each hand-written file over 150 lines.
4. A test-gap/consistency matrix and ordered migration plan with contract-preservation checks.

For an authorized refactor, establish characterization tests first, then move one responsibility at a time. Do not replace the whole backend with a generated layered tree. Stop and request a decision when ownership, business rules, public behavior, or required atomicity cannot be established; report unavailable infrastructure instead of treating fake tests as proof.

## Delivery gate

- [ ] Imports and package APIs enforce the intended dependency direction; top-level `internal/` is not mistaken for sibling-context isolation.
- [ ] Domain invariants, zero values, reconstitution, and event ownership have explicit behavior.
- [ ] Ports belong to consumers; storage/generated types and transaction handles stay outside the core.
- [ ] REST, events, and ACL adapters delegate rather than implement business workflows.
- [ ] Bootstrap/shared packages have narrowly stated responsibilities and no hidden global dependency registry.
- [ ] File actions preserve cohesion; oversized-file review does not introduce artificial packages.
- [ ] Unit tests are co-located; tagged integration/E2E suites under `/test` actually run where required.
- [ ] Public contracts remain unchanged or their changes were separately approved.

Report changed paths, behavior preserved/changed, checks actually executed, failures/skipped checks with reasons, and remaining risks. Never report a template as runnable code or a test as passed without executing it.

## Guide-to-skill correspondence

| Guide sections | Operational reference |
|---|---|
| Introduction, core rules, placement, §17 | [Architecture and structure](references/architecture-and-structure.md) |
| §§1–2, 5–6 | [Domain model](references/domain-model.md) |
| §§3–4, 8, 16 | [Application layer](references/application-layer.md) |
| §§7, 10 | [Persistence and transactions](references/persistence.md) |
| §9 | [Errors](references/errors.md) |
| §11 | [REST and inbound events](references/rest-api.md) |
| §12 | [Context integration](references/context-integration.md) |
| §13 | [Testing](references/testing.md) |
| §§14–15 | [Runtime and observability](references/runtime-and-observability.md) |
| §18 | This source record, delivery gate, and correspondence table |

When updating a rule, compare all affected references, trees, examples, and commands with the guide. Record the reviewed content revision only after semantic review. Historical repositories inform the guide's rationale; they never override these rules simply because their current folders differ.
