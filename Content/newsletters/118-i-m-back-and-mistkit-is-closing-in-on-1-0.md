---
issueNo: 118
buttondownID: em_6pvnxqhx4b9c488xg4cbd92kjp
featuredImage: https://image-generator.buttondown.email/api/emphasize-subject?subject=I%27m%20back%20%E2%80%94%20and%20MistKit%20is%20closing%20in%20on%201.0&author=BrightDigit&date=2026-06-30&img=https%3A//assets.buttondown.email/images/181100fa-6d46-41f6-84ce-957349009a85.png
longArchiveURL: https://buttondown.com/brightdigit/archive/118-im-back-and-mistkit-is-closing-in-on-10/
title: I'm back — and MistKit is closing in on 1.0
date: 2026-06-29 14:36
description: MistKit nears 1.0, the podcast is back plus my take on WWDC 2026 and all that shipped while I was quiet.
---
Hello everyone!

It's been about six months since [the last one of these](http://eepurl.com/jufmOc), and a lot has changed — including the address this email is coming from. More on that in a second. First, the thing I'm most proud of right now.

Back in December I wrote about [**rebuilding MistKit from scratch**](http://eepurl.com/jufmOc) — a 10-year-old CloudKit framework, redone in three months with Claude Code. Here's where that's gotten since: **MistKit is closing in on 1.0**, it's at **248 GitHub stars**, and `1.0.0-beta.2` shipped at the end of May.

![MistKit Logo](https://assets.buttondown.email/images/80374c14-97f5-4fb5-981f-c2a48ff58a69.png?w=960&fit=max)

## MistKit: the road to 1.0

The pitch hasn't changed: **CloudKit is a great backend, right up until you need to reach it from somewhere that isn't an Apple device.** MistKit is the Swift package that closes that gap — talking to CloudKit Web Services from **Android, Windows, Linux, and server-side Swift**.

What's happened since the rebuild is the unglamorous, important part — turning a working prototype into something you'd actually trust in production:

- **beta.1** stabilized the core — CRUD, query pagination, authentication, typed errors.
- **beta.2** filled in what a real backend reaches for next: **push notifications and subscriptions** (yes, APNs registration from a Linux server), a full **Zones API** for sync and change tracking, batch operations that **auto-chunk** so you're not hand-managing CloudKit's limits, and a pass of type-safety hardening so conversion failures are *loud* instead of silently wrong.

It's the same code behind my **"CloudKit as Your Backend"** talk at [Swift Craft](https://www.youtube.com/@SwiftCraftUK) last month, and it's the backend I'm building my own next projects on (Bushel and a new app I'll get to below). `alpha.1` landed back in November — so 1.0 is the end of an eight-month haul, and it's finally in sight.

👉 **[MistKit 1.0.0-beta.2 release notes](https://github.com/brightdigit/MistKit/releases/tag/1.0.0-beta.2)** · **[the repo](https://github.com/brightdigit/MistKit)**

If you're doing anything with CloudKit — or you've ever been told "that only works on Apple's SDKs" — I'd **genuinely love for you to get this a try** before 1.0 and tell me where it falls short.

## Things that changed (and why this email looks different)

While we're catching up, two bigger shifts since you last heard from me:

**The podcast is back, too.** EmpowerApps returned with **Episode 204** in early June after about ten months away, and it hasn't stopped — we're already through Episode 208, with guests like [Joannis Orlandos (Swift on robots and drones)](https://brightdigit.com/episodes/205-who-s-wendy-with-joannis-orlandos/) and [Joe Fabisevich](https://brightdigit.com/episodes/208-everyone-thinks-they-re-good-at-prompting-with-joe-fabisevich/) along the way. You can catch up at **[empowerapps.show](https://www.empowerapps.show)** or [brightdigit.com](https://brightdigit.com/episodes). Two of those episodes are about WWDC — which brings me to the biggest thing in the ecosystem this month.

And the address: **if this email looks different, it is.** BrightDigit's newsletter has moved from Mailchimp to **Buttondown**. You're getting this because you subscribed at brightdigit.com — nothing for you to do, just a cleaner home for these going forward.

## What I made of WWDC 2026

WWDC was a few weeks ago, and after last year's big swings it looked like a refinement year on the surface — iOS 27 as a Snow Leopard–style cleanup. Underneath, though, was the one swing I actually care about: Apple opened up **Foundation Models**. The on-device model got real reasoning and tool-calling, there's a new Private Cloud Compute tier, and — the part that made me sit up — **first-party Swift packages from Anthropic and Google**, so you can drop Claude or Gemini in behind the same `LanguageModel` protocol and swap providers with a single SwiftPM change. Add MLX becoming a first-class citizen and agentic coding built straight into Xcode 27, and it's the most serious Apple has been about giving Swift developers real, swappable, on-device-to-cloud AI infrastructure.

I did three episodes digging into it. 

* [**Episode 206** with **Peter Witham**](https://brightdigit.com/episodes/206-platforms-state-of-the-union-2026-with-peter-witham/) is our yearly tradition of first reactions to the Platforms State of Union. 
* [**Episode 207** with **Cihat Gündüz**](https://brightdigit.com/episodes/207-120-likely-with-cihat-gunduz/) — who runs [WWDC Notes](https://wwdcnotes.com) — is the full breakdown: which APIs matter, which to wait for the .1 on, which sessions are worth your time. 
* [**Episode 208** with **Joe Fabisevich**](https://brightdigit.com/episodes/208-everyone-thinks-they-re-good-at-prompting-with-joe-fabisevich/) (Plinky, Boutique) is the honest AI-assisted-development conversation — how two indie devs actually use these tools day to day, no hype and no doom — plus where Apple really stands. 

All of them are up now at [empowerapps.show](https://www.empowerapps.show) and [brightdigit.com](https://brightdigit.com/episodes).

## What else shipped while it was quiet

None of the MistKit progress happened in a vacuum. Almost everything I shipped this spring came out of the same habit: **building real apps on my own libraries**, then fixing whatever breaks.

- **SundialKit v2** — a ground-up rearchitecture into a plugin family: a `SundialKitCore` of protocols and typed errors, two interchangeable reactive backends (**[SundialKitStream](https://github.com/brightdigit/SundialKitStream)** for async/await, `SundialKitCombine` for Combine), and an opt-in `SundialKitContext` so you only link `@Observable` if you want it. It exists because I needed reliable Watch-to-iPhone sync for a real app, and the old design wasn't cutting it. That reliability work landed as **ContextEngine** in SundialKitStream. (Turns out `updateApplicationContext` confirms the *call* succeeded, not that your watch actually got the data. That's a distributed-systems problem wearing an iOS costume.) → [releases](https://github.com/brightdigit/SundialKit/releases)

https://www.youtube.com/watch?v=-A6GjyuMwUk

- **AtLeast** — the app driving all of that: a watchOS "at least X minutes" timer that rewards you with silence once you've done enough. **Now in beta on TestFlight** → [atleast.app](https://atleast.app).
- **swift-build** — the GitHub Action that turns 100+ lines of Swift CI into five, now through **v1.5.7**, covering everything from visionOS to Windows Server to WebAssembly.

[![MonthBar in the macOS menu bar, showing how much of the month is left](https://attachments.buttondown.com/images/4e68b2da-47da-4960-9d1c-3bb13b15993d.gif?fit=max)](https://month.bar)

- [**MonthBar**](https://month.bar) — my little macOS menu-bar app for seeing how much of the month is left (handy for pacing your AI token budget) is **out now** → [month.bar](https://month.bar).
- **[Celestra](https://celestr.app)** — and the thing I'm building next: an RSS reader (on SyndiKit + MistKit) that uses Apple's Foundation Models to suggest what's actually worth reading. Still early — more when there's something to show.

One bit of community news worth a mention while we're here: the **[Swift Package Index is joining Apple](https://swiftpackageindex.com/blog/swift-package-index-joins-apple)**. It's become essential infrastructure for how we all find and trust Swift packages, so it's good to see it land somewhere with the resources to keep it going.

[![Swift Package Index with Dave Verwer and Sven Schmidt](https://assets.buttondown.email/images/65a18ad9-62da-4418-b20c-41adba9345c8.jpg?w=960&fit=max)](https://brightdigit.com/episodes/141-swift-package-index-with-dave-verwer-and-sven-schmidt/)

If you are interested in learning more, check out [the episode we did with Dave Verwer and Sven Schmidt a few years ago to learn more.](https://brightdigit.com/episodes/141-swift-package-index-with-dave-verwer-and-sven-schmidt/)

## Where you can find me this summer

I gave the MistKit / CloudKit-as-backend talk at **[Swift Craft](https://swiftcraft.uk/2026)** (Folkestone) in May — the recording isn't out yet, but it'll land on the [Swift Craft YouTube channel](https://www.youtube.com/@SwiftCraftUK), and I'll share it the moment it does. Still ahead:

- 🇺🇸 **[Beer City Code](https://www.beercitycode.com/)** — Grand Rapids, Aug 14–15 (*The Automation Stack* + *Vibe Coding*)
- 🇬🇧 **[iOSDevUK](https://www.iosdevuk.com/)** — Aberystwyth, Wales, Sept 7–10 (*CloudKit as Your Backend*)

If you'll be at either, find me — the hallway track is my favorite part.

## One ask: let's talk

Consulting is open again, and I mean it. If you've got a Swift project that's stuck — **CI/CD, CloudKit / server-side Swift, package architecture, SwiftData, or figuring out where AI tooling actually helps** — I'd love to help.

**Book a free 30-minute consult, no funnel, no pitch:** **[zcal.co/leogdion/consultation](https://zcal.co/leogdion/consultation)**

Or just hit reply and tell me what you're stuck on. If I can help, I'll tell you how. If I can't, I'll point you at someone who can.

## Coming up

Now that I'm back on a regular cadence, the next couple of issues each go deep on one thing instead of cramming it all in here. First up: [my AI-assisted-development conversation with **Joe Fabisevich**](https://brightdigit.com/episodes/208-everyone-thinks-they-re-good-at-prompting-with-joe-fabisevich/) — the honest version of where this tooling actually is in 2026. After that, **[AtLeast's public beta](https://atleast.app)** — the little watch app that kicked off all the reliability work. Both soon.

It's good to be back. Reply and tell me what *you've* been building these last six months — I read every one.

Happy building!

— Leo

---

*Leo Dion · BrightDigit · [empowerapps.show](https://www.empowerapps.show) · [@brightdigit](https://twitter.com/brightdigit) · [YouTube](https://youtube.com/c/BrightdigitLLC) · leogdion@brightdigit.com*
