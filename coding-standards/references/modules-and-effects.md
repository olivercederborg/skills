# Modules and effects

Domain Module, Application Service, Adapter, and composition root name responsibilities. They do not require matching folders, suffixes, symbols, or repository vocabulary. Use only the roles the behavior needs.

```txt
external input -> inbound Adapter -> Application Service -> Domain Module
                                           |
                                           +-> application-owned port
                                                 -> outbound Adapter -> external system
```

A pure operation with no application policy or effects can go directly from an inbound adapter to a Domain Module.

## Choose ownership

Classify code by what would make it change:

- A business meaning, invariant, calculation, or legal state transition belongs to a Domain Module.
- Application policy, authorization, or effect order belongs to an Application Service.
- Protocol, framework, database, runtime, or provider translation belongs to an Adapter.
- Construction, configuration, and resource wiring belong to the composition root.

Trace one caller-visible operation from input through every effect. Assign each part to the narrowest owner. Use the project's layout and vocabulary. Limit migration to the behavior being changed.

## Deep modules

A deep module hides meaningful behavior, policy, sequencing, or translation behind a cohesive interface. Avoid modules that only forward calls, mirror tables, rename another API, or expose implementation steps.

Use the deletion test:

- If deleting the module removes complexity, the module may be pass-through waste.
- If deleting it spreads complexity across callers, the module is useful.

Add a module only when it hides current complexity, removes current duplication, or prevents invalid use.

## Domain Modules

A Domain Module owns one domain type or a closely related type family. It defines valid values and legal operations without I/O.

Use one for a domain distinction, invariant, calculation, decision, or lifecycle. Keep a primitive or local function when a module would enforce no rule and prevent no invalid use.

A Domain Module can own parsers, smart constructors, predicates, transitions, projections, formatting, and test generators. It should return refined values, express expected failures precisely, and avoid frameworks, persistence, ambient time, randomness, and mutable global state.

It may define a pure permission decision. It should not authenticate callers, gather authorization context, enforce a decision during an operation, order effects, query storage, call a network, or expose transport records.

## Application Services

An Application Service owns one application operation or capability. It applies policy and orders effects through application-owned ports.

Use one when it hides meaningful authorization, policy, or effect sequencing, or when several entrypoints must call the same operation. Do not add one only because an operation uses time, IDs, telemetry, or a single dependency.

An Application Service should accept and return application or domain types, expose precise expected failures, receive dependencies explicitly, and remain independent of HTTP, queues, ORMs, vendor SDKs, and runtime types.

Use the repository's dependency-injection pattern. In Effect codebases, use services, tags, and Layers. Avoid passing a dependency bag into every call.

## Adapters

An inbound adapter parses an external request, event, or command, calls application or domain code, and projects the result into the external protocol.

An outbound adapter implements an application-owned port with a concrete technology. It translates raw records, SDK values, and external failures into application or domain types and typed errors.

Add an adapter when it hides meaningful protocol translation, lifecycle work, error classification, retry behavior, or technology mechanics. Do not add a pass-through adapter that only forwards the same shape.

Adapters may perform a short technical retry only when the operation is safe to repeat and the retry does not change the port's meaning. They must not decide business eligibility, authorization policy, legal state transitions, or application effect order.

Inbound authentication adapters verify credentials and produce a parsed identity such as `Principal` or `Session`. Application Services gather context and enforce permission decisions. Adapters translate missing credentials, invalid credentials, and denials into protocol outcomes. They do not define permission policy.

## Composition root and resources

The composition root parses configuration, acquires resources, constructs adapters, and supplies them to Application Services. Keep domain rules and application policy out of it.

Parse environment values at startup. Use typed and redacted configuration where needed. Do not read `process.env` throughout the application.

Make resource creation and cleanup explicit. Avoid import-time I/O, mutable global state, and hidden singletons. Isolate a framework-required singleton at its boundary. Inject clocks and randomness into dependency-bearing modules.

## Ports and reuse

Define a port beside the Application Service that needs it and in application language. Use the smallest meaningful capability. A cohesive adapter may implement a wider interface.

Port inputs, outputs, and errors should be application or domain types, not database rows, SDK objects, or framework values.

Before creating an adapter or service:

1. Reuse an existing one through a narrow dependency type.
2. Extend one when the method belongs to the same cohesive capability.
3. Create one when reuse would cause bad coupling or an accidental interface.

Record a decision only for a lasting architectural boundary, shared pattern, provider strategy, or deliberate exception. Explain what was checked and why reuse did not fit.

## Persistence

Avoid repository-per-table by default. A repository-like adapter should represent a cohesive domain persistence capability, expose meaningful operations, and return parsed domain types and typed errors.

Keep raw rows, ORM models, SQL, and transaction mechanics inside persistence adapters or modules. Parse records before they enter application or domain code.

## Workflows, transactions, and idempotency

Use ordinary calls or a database transaction for a simple, single-boundary operation. Do not hold a transaction open across a network call or long-running work.

Use a durable workflow when progress must survive process loss or redelivery, or when the operation needs a long delay, compensation, resumability, a timer, human approval, cross-service coordination, or several transaction boundaries.

Adapters own safe, short technical retries. Application Services decide whether an operation should run again. Durable workflows own retries that must survive a crash, delay, or redelivery.

Every retriable external mutation or state transition needs an explicit idempotency strategy, such as a stable key, unique constraint, deduplication record, guarded state transition, or transactional outbox or inbox. Never assume a repeated side effect is safe.
