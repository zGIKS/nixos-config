---
name: ddd-flutter
description: Implement a complete Domain-Driven Design (DDD) bounded context in a Flutter/Dart 3 frontend — value objects, commands, queries, events, domain services, infrastructure gateways (Dio), application services (Riverpod codegen), REST resource contracts, screen orchestration (go_router), widgets/forms, and cross-context ACL. Use whenever asked to build, scaffold, or review a bounded context, feature module, screen, or CQRS layer in a Flutter/Dart codebase following DDD patterns.
---

# DDD Bounded Context Implementation (Flutter)

Baseline stack: Dart 3.x (sound null safety, sealed classes, pattern matching), Flutter 3.x, Riverpod with code generation (`riverpod_generator`), Freezed 3, `go_router`, `Dio`.

Naming principle is mandatory across the whole context: **Descriptive/Role-based Naming** or **Explicit Transformation Naming**.

Keep business ownership explicit, dependencies inward, and UI thin. Tactical patterns are applied only when they protect real invariants or clear boundaries.

## Core rules

1. Completely avoid creating DTO classes.
2. Completely avoid mapper classes.
3. Appropriately documented responses in Swagger/OpenAPI must be consumed as contract in frontend.
4. Do not use fake API in runtime flow; consume real API endpoints.
5. Use **Riverpod with code generation** (`@riverpod`/`riverpod_generator`) as the default DI and state-management mechanism; do not mix it with `GetIt`/`Provider` in the same context.
6. Model domain unions (result types, status enums with payloads) with **Dart 3 sealed classes and pattern matching** (`switch` expressions, exhaustiveness checking) instead of boolean flags or stringly-typed status fields.
7. Use **Freezed 3** (`@freezed` with the new `sealed`/`abstract class` syntax) for immutable value objects, commands, queries, events, and resources instead of hand-rolled immutable classes, unless the team has an explicit reason to avoid codegen.
8. Use **`go_router`** for navigation/route orchestration; route-level orchestrators receive typed route params, not raw `Map<String, String>` extras.
9. Target **null-safety-complete, sound Dart 3.x** code; avoid `dynamic` at domain/application boundaries.

## Build order

Follow this order — load each reference only when you reach that step; don't front-load all of them.

| # | Step | Reference |
|---|------|-----------|
| 1 | Value objects (IDs, validated primitives) | [references/value-objects.md](references/value-objects.md) |
| 2 | Enums/sealed unions | — (Dart 3 enums or sealed classes, no reference needed) |
| 3 | Commands & Queries | [references/commands-and-queries.md](references/commands-and-queries.md) |
| 4 | Domain services (abstract classes) | [references/domain-services.md](references/domain-services.md) |
| 5 | Entities/Aggregates | — (reuse shared frontend core folder for ID/audit fields when available) |
| 6 | Domain events | [references/events.md](references/events.md) |
| 7 | Infrastructure gateways (real API, Dio) | [references/infrastructure-gateways.md](references/infrastructure-gateways.md) |
| 8 | Command/Query service implementations (Riverpod codegen) | [references/application-services.md](references/application-services.md) |
| 9 | REST resources (frontend contracts) | [references/rest-resources.md](references/rest-resources.md) |
| 10 | Frontend controllers/screens (orchestration, `go_router`) | [references/pages-and-orchestration.md](references/pages-and-orchestration.md) |
| 11 | Widgets & forms | [references/widgets-and-forms.md](references/widgets-and-forms.md) |
| 12 | Transformers, guards/interceptors/routes | — (`go_router` redirects/guards, Dio interceptors) |

If the context needs to talk to another bounded context, add the **ACL layer** — see [references/acl-cross-context.md](references/acl-cross-context.md). Never let contexts call each other directly.

## Architectural references

- Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software* — tactical building blocks in client architectures.
- Flutter Documentation — declarative UI state management and route orchestration.
- Dart 3 Language Specification — sealed classes, pattern matching, exhaustiveness checking, and sound null-safety.
- Remi Rousselet, *Riverpod Architecture Guide* (`riverpod.dev`) — functional dependency injection and reactive state caching.
- Freezed Code Generation Documentation (`pub.dev/packages/freezed`) — immutable unions and data modeling.
