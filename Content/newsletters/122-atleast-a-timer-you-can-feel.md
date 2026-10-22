---
issueNo: 122
buttondownID: em_53saqvhc869y8atnswv142xppm
featuredImage: https://assets.buttondown.email/images/ec33e9d2-090f-4798-b30d-333091214ecc.png?w=960&fit=max
longArchiveURL: https://buttondown.com/brightdigit/archive/atleast-a-timer-you-can-feel/
title: 'AtLeast 1.0: a timer you can feel'
date: 2026-10-21 13:31
description: Gentle taps on your wrist, silence when you're done. What's in 1.0, what's in Pro, and one small favor for Nov 10.
---
**If you have an Apple Watch, I'd love for you to try it: [AtLeast on the App Store](https://apps.apple.com/us/app/atleast-silent-timer/id6759622997).**

[![AtLeast – Silent Timer, now on the App Store](https://assets.buttondown.email/images/ec33e9d2-090f-4798-b30d-333091214ecc.png?w=960&fit=max)](https://apps.apple.com/us/app/atleast-silent-timer/id6759622997)

If you missed [the beta issue](https://buttondown.com/brightdigit/archive/atleast-is-in-beta-the-watch-timer-that-tells-you/), here's the short version. I have recurring TMJ, and part of managing it is slowing down: breathing, quiet time, a few minutes at a time. I keep my eyes closed when I do that, and every timer I tried ends with an alarm I have to open my eyes and tap. So I built one I can *feel*. It taps my wrist to say keep going. When the taps stop, I've done my minimum, and there's nothing to dismiss, so if I want to keep going, I just do.
## What's in 1.0
![AtLeast on Apple Watch: pick a timer, a soft green glow while it taps, and the finish screen once you pass your minimum](https://assets.buttondown.email/images/6fd05976-11af-4478-a319-ccc61fbd2d60.png?w=960&fit=max)

- **Taps during, silence when you're done.** Set a minimum from 1 to 60 minutes and how often you want a tap. There's no alarm at the end and nothing to dismiss. Keep going as long as you like.
- **Six haptic strengths**, from gentle to max. Beta testers told me the early taps were "too polite," so now you choose.
- **iPhone and Apple Watch together.** Pick a timer on your iPhone and it pre-loads on your watch. Press Start on your wrist, and your iPhone mirrors the live session. No watch with you? Run the session on the iPhone itself.
- **Apple Health, your way.** Give a timer a Session Type and each finished session is saved as Mindful Minutes or a workout like Yoga. Pick it per timer, so a sit and a stretch each count as what they were. AtLeast only writes to Health. It never reads it.
- **Private by design.** Everything runs on-device. There's no account, and your timers and history sync through your own iCloud.

![The iPhone companion: pick a timer, press Start on your Apple Watch, and the iPhone mirrors the live session](https://assets.buttondown.email/images/84eb973c-7beb-4a4e-a01b-0b895df329ce.png?w=960&fit=max)

The free app does everything I built it for: the timer, the built-in timers, the iPhone companion, and Mindful Minutes and Yoga saved to Health.

## AtLeast Pro

Pro is for when you want more:

- **Your own timers**, saved and ready to go
- **History**: every finished session grouped by day, with streaks and quiet minutes
- **Every Session Type**: Flexibility, Cooldown, Core Training, Traditional Strength, and more

![AtLeast Pro: History with streaks and quiet minutes, and a session's detail showing when the minimum was reached](https://assets.buttondown.email/images/bb6849ff-7d45-4fbd-97ce-c1c48220596f.png?w=960&fit=max)

It's $0.99 a month, or $9.99 a year with a 7-day free trial. There's also a one-time **AtLeast Founder** option if you'd rather pay once and support the app.

## More than meditation

A lot of things have the same shape: a floor, not a countdown. I use it eyes closed with ear plugs in, for at least 15 minutes. It also works for:

- **Cold plunges**, where you really don't want to look at a screen
- **Yoga and stretching**, holding a pose with a rhythm on your wrist
- **Planks and wall sits**, so you feel the time instead of watching it
- **Focused work**, Pomodoro-style, with a quiet finish

Anything where the point is to *at least* do it, and keep going if it feels right.

I made a two-minute video for RevenueCat's Shipaton that shows it on a wrist:

https://youtu.be/uGqpKWTIwFw

## One small favor: Tuesday, November 10

AtLeast is featured on **[Uplift Indie on November 10](https://www.upliftindie.app/day/2026-11-10)**. Uplift Indie is a community calendar where indie developers download each other's apps and leave honest reviews. If you've used AtLeast, that's a great day to leave a rating or a review on the App Store. And if you haven't tried it yet, that's a good day to start.

## Built alongside a few other things

AtLeast is the app that pushed a lot of my open source forward this year:

- **[SundialKit v2](https://github.com/brightdigit/SundialKit)**: the Watch↔iPhone communication layer behind AtLeast's sync
- **[SundialKitStream 1.0](https://github.com/brightdigit/SundialKitStream)** (out Oct 4): async streams over SundialKit
- **[DictionaryCoding 1.0](https://github.com/brightdigit/DictionaryCoding)** (out Oct 4): a small new package for `Codable` to and from `[String: Any]`, for the message passing

I'll go deeper on those in a later issue. One of them involves a crash that happened 23 minutes into every session, and how I tracked it down.

## What I'd love from you

Try it on your wrist and tell me **what still feels off**. Is a tap too strong, a session too long, or a moment where you looked at the screen when you shouldn't have needed to? Just reply to this email. I read every one.

And one more: **Daniel Steinberg is coming back on EmpowerApps.** We record on **Wednesday, October 28**, and we're talking about what's new in **Foundation Models**. What would you ask him? Reply with a question before the 28th and I'll bring the good ones in, with credit.

👉 **[AtLeast on the App Store](https://apps.apple.com/us/app/atleast-silent-timer/id6759622997)**

Thanks for following along from beta to 1.0.

Leo

P.S. Next up: two talks in two countries, and what each one did to the tools behind it.

{{ subscribe_form }}