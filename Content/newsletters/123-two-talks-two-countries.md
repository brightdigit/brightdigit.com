---
issueNo: 123
buttondownID: em_5m5tcv4w8t89v9n5r7pt4mfb9k
featuredImage: https://assets.buttondown.email/images/708ebe3a-35c5-4cf6-90c3-7ba8ff90eefc.jpg?w=960&fit=max
longArchiveURL: https://buttondown.com/brightdigit/archive/two-talks-two-countries/
title: Two talks, two countries
date: 2026-11-09 21:06
description: iOSDevUK in Wales, a workshop in Berlin, how much AI came up at both, and a CloudKit talk at CodeMash in January.
---
Hello everyone!

This fall I spoke at two conferences. Even though I didn't talk directly about AI, AI was all over both.

![Me speaking at iOSDevUK](https://assets.buttondown.email/images/708ebe3a-35c5-4cf6-90c3-7ba8ff90eefc.jpg?w=960&fit=max)

## iOSDevUK: CloudKit as Your Backend

My talk landed the same day as the Nintendo Direct and the iPhone Duo announcement, so I opened with an AI-generated render of the nonexistent game [Super Mario Titans](https://knowyourmeme.com/memes/events/super-mario-titans) running on an iPhone Duo. That's the slide behind me in the photo up top.

The rest of the talk was [MistKit](https://github.com/brightdigit/MistKit) again: how to use CloudKit from places the CloudKit framework doesn't work, like a server, a Linux box, or a GitHub Action. I covered authentication, type safety, error handling, and the API design that sits over a generated OpenAPI client.

One question I keep coming back to since [iOSDevUK](https://www.iosdevuk.com/) in Aberystwyth: if CloudKit works from a server or a Linux box, how useful could it be for the Android and Windows users of an app? That's the part of "CloudKit from anywhere" I want to push on next.

**AI at iOSDevUK:** Graham Lee's talk stood out. He walked through the different patterns for working with AI in software development, which is also what we talked about [when he was on the podcast](https://brightdigit.com/episodes/216-do-the-wrong-thing-much-faster-with-graham-lee).

If you want the story behind MistKit's rebuild, I wrote it up:

👉 **[Read the blog post: Rebuilding MistKit with Claude Code](https://brightdigit.com/tutorials/rebuilding-mistkit-claude-code-part-1/)**

{{ subscribe_form }}

https://youtu.be/NyKmqtklU-U

## swiftCon Berlin: Building Scalable Swift Automation

My first time speaking in Berlin. The talk covered:

- **Project setup** with [mise](https://brightdigit.com/tutorials/mise-setup-guide/) for your tools and [Tuist](https://brightdigit.com/tutorials/tuist-xcode-project-setup/) so the Xcode project is Swift code, not a `.pbxproj` nobody can merge
- **Signing and TestFlight** with [Fastlane Match](https://docs.fastlane.tools/actions/match/) and GitHub Actions: an archive on every PR, a TestFlight build on main
- **Cross-platform testing** with the [swift-build](https://github.com/brightdigit/swift-build) action on Linux, Windows, Android and WASM, and Swift Testing traits so platform-specific tests are skipped on purpose

👉 **[Watch the recording here](https://youtu.be/NyKmqtklU-U)**

👉 **[Slides and links from the talk](https://buttondown.com/brightdigit/archive/swift-automation-talk-slides-and-links/)**

**AI at swiftCon:** [next.app devCon](https://www.nextappcon.com/swiftcon) runs a lot of topics like IT security and mobile development, and agentic programming was a big part of the conference.

## New Episodes

Speaking of AI, I just released my episode with Daniel Steinberg, [You're Better Than AI](https://brightdigit.com/episodes/217-you-re-better-than-ai-with-daniel-steinberg) where we talk about using Foundation Models, Apple's framework for using AI in your app. And Patreon members get first listen to [Not Accessible by Default with Rob Whitaker](https://www.patreon.com/brightdigit/posts/not-accessible-174590756), which comes out next week.

## Next: CodeMash, January 2027

I'm happy to say **CodeMash 2027 accepted [CloudKit as Your Backend](https://events.codemash.org/2027CodeMashConference#/acceptedSpeakers).** It's January 12–15 at the Kalahari in Sandusky, Ohio. CodeMash is a polyglot conference, so this is the talk in front of a room that mostly doesn't write Swift. That makes it a good test of whether "CloudKit from anywhere" really holds up. If you're going to CodeMash, let me know. I'd love to say hi.

## One more thing: consulting

I'm putting together a few fixed-scope consulting packages built on this work: CI/CD setup, Swift package architecture reviews, and adding AI to a Swift workflow. More on that soon. Until then, the [free 30-minute call](https://zcal.co/leogdion/consultation) is still open if you want to talk through your setup.

Thanks for reading, and for the questions after both talks.

Leo

P.S. Next issue: five podcast episodes, our first video episodes, and AI, the topic four of those guests ended up on.
