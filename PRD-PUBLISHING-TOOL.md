# Product Requirements Document: Swift Publishing Tool

## Overview

Build an open source Swift package that integrates into the BrightDigit.com static site generator (currently Publish; migration in progress per brightdigit/brightdigit.com#31) to publish content across multiple channels — newsletter and social media. The tool must work without storing any audience data in the repository.

Two transports are needed:

| Channel | Platform | API Style | Code Generation |
|---|---|---|---|
| Newsletter | Buttondown | REST (OpenAPI 3.0.2) | swift-openapi-generator |
| Social media | Buffer | GraphQL | None — handwritten client via ClientTransport |

---

## Constraints Driving the Architecture

### Open Source Repository

The tool is open source. Subscriber emails and audience data cannot live in the repo. All credentials are environment variables. All audience data is managed by the platform.

This eliminates Mailgun as a full newsletter solution: Mailgun requires owning a subscriber list, which has no safe home in an open source project. Buttondown manages subscribers server-side — the tool only ever touches an API key.

### General-Purpose Publishing

The tool publishes beyond newsletters: social posts go to Buffer, which fans out to X/Twitter, LinkedIn, Mastodon, and others from a single API call. Each platform's audience is managed by that platform.

```
BUTTONDOWN_API_KEY=...   # env var — newsletter subscribers on Buttondown's servers
BUFFER_API_TOKEN=...     # env var — social audiences on Buffer's servers
```

No audience data in the repo. Fully open-sourceable.

### Linux Compatibility

The tool runs as part of a publishing pipeline that must work on Linux (CI/CD, server-side Swift). All HTTP clients use the `ClientTransport` protocol from `swift-openapi-runtime`, which allows swapping the underlying transport:

```swift
// On Linux:
let transport: any ClientTransport = AsyncHTTPClientTransport()
// swift-server/swift-openapi-async-http-client

// On Apple platforms:
let transport: any ClientTransport = URLSessionTransport()
// apple/swift-openapi-urlsession
```

This applies to both the Buttondown generated client and the Buffer handwritten client.

---

## Newsletter Transport: Buttondown

### Protocol Architecture

> **Note:** Exact protocol shapes are TBD and will be finalized during implementation. The split below reflects the architectural intent, not a final API.

Newsletter functionality should be split into (at least) two separate concerns:

- **Subscriber list management** — fetching/managing the list of recipients
- **Email sending** — delivering a composed issue to recipients

This separation matters because different platforms cover different concerns:
- **Buttondown** handles both — its API manages subscribers and sending
- **Mailgun** handles only sending — it is a transactional email API, not a list manager

Splitting these concerns means Mailgun can be composed with a separate list provider (e.g., Buttondown's subscriber API, a private CSV, or another list service) without requiring a full platform swap. The exact protocol signatures (method names, parameter types, return types) will be determined once implementation begins.

### Why Not Mailgun (as a complete solution)

Mailgun is a transactional email API — it sends messages but does not manage subscribers. Owning the subscriber list means storing ~400 email addresses somewhere. In an open source repo, the only safe options are an external private database or a private file outside the repo — both adding infrastructure the tool depends on but cannot ship with.

Mailgun also requires:
- HTML conversion from markdown (Mailgun does not render markdown)
- A hosted unsubscribe endpoint (required for CAN-SPAM compliance)
- Per-subscriber send loop instead of a single campaign call
- Bounce/complaint webhook handling

Mailgun remains a viable `NewsletterSender` implementation when paired with a separate list provider.

### Why Buttondown

Buttondown's API is newsletter-native. Sending an issue is two REST calls:

```
POST /emails              → create draft (body is markdown string)
POST /emails/{id}/send-draft  → send to all subscribers
```

Everything else — subscriber management, unsubscribe links, bounce handling, CAN-SPAM compliance, deliverability — is managed by Buttondown.

**Official OpenAPI spec:** [github.com/buttondown/openapi](https://github.com/buttondown/openapi) (3.0.2)
Compatible with swift-openapi-generator. The spec is newsletter-scoped, so the generated client surface is small and directly useful: `Email`, `EmailCreate`, `Subscriber`.

**Cost:** $9/month. This buys the entire subscriber infrastructure layer.

### Pivot Path

Conceptually (exact types TBD):

- `ButtondownTransport` — implements both list management and sending via the Buttondown API
- `MailgunTransport` — implements sending only; compose with a separate list provider

Buttondown exports subscribers as CSV, so migrating the list to a private store is straightforward if the architecture ever changes.

---

## Social Transport: Buffer

### Why Buffer

Buffer is a social media scheduling platform with a single API that publishes to multiple networks. One GraphQL mutation reaches X/Twitter, LinkedIn, Mastodon, Instagram, Threads, Bluesky, and more. This eliminates the need to integrate each platform's API individually — no per-platform OAuth flows, token management, or rate limit handling.

All social audiences are managed by Buffer. The tool sends content; Buffer knows where it goes.

**API style:** GraphQL (new API, in early access)
**Auth:** Bearer token (`Authorization: Bearer $BUFFER_API_TOKEN`)
**HTTP layer:** `ClientTransport` from `swift-openapi-runtime` — Linux-compatible

### Publishing Flow

The Buffer GraphQL mutation is sent as a plain HTTP POST with a JSON body — no Apollo, no code generation dependency. Exact implementation shape is TBD, but the general approach:

- `BufferTransport` wraps a `ClientTransport` instance
- Encodes the GraphQL mutation as `{"query": "...", "variables": {...}}`
- Decodes the response with `Codable`

```graphql
mutation CreatePost {
  createPost(input: {
    text: "...",
    channelId: "...",
    schedulingType: automatic,
    mode: shareNow        # or addToQueue for scheduling
  }) {
    ... on PostActionSuccess { post { id } }
    ... on MutationError { message }
  }
}
```

Using `ClientTransport` means the same platform-swap pattern (AsyncHTTPClientTransport vs URLSessionTransport) works for Buffer as it does for Buttondown — no Apollo iOS required.

---

## Package Structure

> **Note:** Module names and file layout are illustrative — final structure TBD during implementation.

```
Sources/
  PublishKit/           # Core logic, Publish plugin entry point
    Publisher.swift     # Orchestrates transports
    MarkdownParser.swift
    Protocols/          # Newsletter + social protocol definitions (shapes TBD)
  ButtondownKit/        # Newsletter: list management + sending via Buttondown API
    ButtondownTransport.swift
    # Generated via swift-openapi-generator from openapi.yaml
    # HTTP layer: ClientTransport (AsyncHTTPClientTransport or URLSessionTransport)
  MailgunKit/           # Newsletter: sending only (no list management)
    MailgunTransport.swift
    # HTTP layer: ClientTransport
  BufferKit/            # Social: handwritten GraphQL client
    BufferTransport.swift
    # HTTP layer: ClientTransport — plain POST to GraphQL endpoint
    # No Apollo, no code gen dependency — Linux-compatible
```

---

## Credential Model

| Variable | Used By | Never Stored In |
|---|---|---|
| `BUTTONDOWN_API_KEY` | ButtondownKit | Repo, subscriber list |
| `BUFFER_API_TOKEN` | BufferKit | Repo, audience data |

---

## Decision Summary

| Decision | Choice | Reason |
|---|---|---|
| Newsletter platform | Buttondown | Open source constraint eliminates subscriber ownership; REST + official OpenAPI spec; markdown-native |
| Social platform | Buffer | Single API for all networks; GraphQL early access available; no per-platform integration |
| Newsletter architecture | Split `SubscriberListProvider` + `NewsletterSender` | Mailgun = sender only; separation allows composition with any list provider |
| Newsletter code gen | swift-openapi-generator | Official OpenAPI 3.0.2 spec from Buttondown |
| Social code gen | None | Buffer API is GraphQL; handwritten Codable client requires no code gen dependency |
| HTTP transport abstraction | `ClientTransport` (swift-openapi-runtime) | Swap `AsyncHTTPClientTransport` (Linux) / `URLSessionTransport` (Apple) — applies to all clients |
| Subscriber storage | None (Buttondown-managed) | Cannot store audience data in open source repo |
| Integration target | BrightDigit.com SSG (Publish, migration pending) | Tool is a publishing pipeline plugin, not a standalone CLI |
