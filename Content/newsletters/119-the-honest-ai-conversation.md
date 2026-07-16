---
issueNo: 119
buttondownID: em_23avv9qdss884bv5sy681b6f1b
featuredImage: https://i.ytimg.com/vi/1vOBfkxAHfY/maxresdefault.jpg
longArchiveURL: https://buttondown.com/brightdigit/archive/119-the-honest-ai-conversation/
title: The Honest AI Conversation
date: 2026-07-13 16:08
description: What AI-assisted development actually looks like in 2026
---
# The Honest AI Conversation

Hello everyone!

Since ChatGPT first launched, my feelings on AI have wavered from skepticism to dread to genuine interest. One side sells you the [singularity](https://www.ibm.com/think/topics/technological-singularity); the other tells you it's all a [bubble about to pop](https://www.forbes.com/sites/josipamajic/2026/07/04/credible-ai-lab-critics-pile-up-as-the-bubble-math-worsens/). And in between — while we're just trying to keep our careers intact — [upper management wants us tokenmaxxing](https://www.tomshardware.com/tech-industry/big-tech/big-tech-has-a-tokenmaxxing-habit), but [not *too* much](https://futurism.com/artificial-intelligence/ceos-reverse-course-ai-spending).

The conversation we should actually be having is about the real-world use of AI, the good and the bad, that's happening right now.

{{ subscribe_form }}

## What is *Vibe Coding*

I've spent the last stretch on a talk to help folks get started — **Vibe Coding: Finding Your Rhythm Between AI Assistance and Human Expertise**, which I brought to CocoaHeads Boston and DC iOS this spring. 

https://www.youtube.com/watch?v=EkudegOD2FU

The core of it is a catalog of the ways these tools reliably let you down and how to work around them. Six of them, and if you've used Claude Code, Cursor, or Copilot you've hit at least half:

- **[Hallucinating](https://www.ibm.com/think/topics/ai-hallucinations)** — confidently inventing APIs that don't exist.
- **Forgetting** — reintroducing the exact mistake you corrected two messages ago.
- **Whack-a-Mole** — every fix spawns a new bug.
- **Power Grabbing** — you asked for error handling in one function; it refactored a shared dependency.
- **Scope Creep** — you asked for a `try/catch`; it built you an offline-mode request queue.
- **[Reward Hacking](https://www.anthropic.com/research/emergent-misalignment-reward-hacking)** — hardcoding answers to make the tests pass instead of fixing the logic.

There are 2 main ideas from it which do most of the work against those failure modes. The first is the **slop plate**.

### Your Context is Sloppy

Your context window isn't a neat little bento box, it's a slop plate of everything feed into your AI tool — prompt, conversation, and instructions all pile onto it, and **once it's crowded the model starts forgetting and hallucinating**. So, as I tell every room: *"keep your slop plate tidy and small."* 
- Clear it often
- Use documentation to hold what matters

### Automate BY AI, not WITH AI

The second is a phrase I keep coming back to: **automate BY AI, not WITH AI**. Don't burn tokens having the model hand-edit forty files — have it write the inspectable bash script instead. When I want my Swift files split so each holds one type, I don't make Claude do it by hand; I have it *write the script that does it.* Use the model to build the guardrails and tooling that keep *you* in control, rather than handing it the wheel.

[![Everyone Thinks They're Good at Prompting with Joe Fabisevich](https://i.ytimg.com/vi/yFPlov0UTZ4/maxresdefault.jpg)](https://brightdigit.com/episodes/210-practical-agents-with-donny-wals)

## Everyone Thinks They're Good at Prompting

On **[Episode 208](https://brightdigit.com/episodes/208-everyone-thinks-they-re-good-at-prompting-with-joe-fabisevich/)**, I chatted with **Joe Fabisevich**: indie dev behind [Plinky](https://plinky.app) and the [Boutique](https://github.com/mergesort/Boutique) persistence library. He's one of the most level-headed writers on [engineering and AI I know and hosts the fantastic blog at build.ms](https://build.ms).

Today most of my work runs through Claude Code, including the [MistKit rebuild](https://github.com/brightdigit/MistKit). Joe walked his own version of that road as an indie. And he had his own thoughts.

**Everyone thinks they're good at prompting.** That's the line the episode is named for — and Joe means it as a challenge. Prompting, he argues in [his mental model for prompting LLMs](https://build.ms/2024/11/14/prompting-large-lanuage-models/), is a learnable skill, not an innate one:

> Prompting is a skill. It's like a skill of context building.

He's blunt about what that skill actually is underneath:

> This is basically a communication workshop, but if I sold it as that, no one would pay me $1,000.

The uncomfortable takeaway: most of us are worse at this than we think, and it's something you can practice.

**Work slop.** Joe's [term for AI output](https://build.ms/2026/3/23/workslop/) that *looks* like finished work but creates more cleanup downstream than it ever saved. He roots it in a familiar temptation:

> [Work slop is] the desire to take shortcuts… to prioritize short-term returns over long-term benefits.

The antidote is the one rule I close every talk with — **always have a human in the loop.** Code review before merging, real testing, someone who owns the outcome. Skip all that, and workslop is exactly what you get. Joe just gave the failure mode a name.

**Building for the agents, not just through them.** Joe built [Broadcast](https://github.com/mergesort/Broadcast), a logging library he [designed for both audiences at once](https://build.ms/2026/6/26/your-agent-deserves-logs/):

> Optimized for human readability… but also optimized for agents to debug your hardest of problems.

His reasoning stuck with me:

> A screenshot is just a moment in time, but logs are forever.

If you want the model to fix your gnarliest bug, give it something it can actually read.

**Where Apple fits.** Tying back to WWDC26 — Foundation Models going open, the first-party Claude and Gemini Swift packages — Joe's honest read landed:

> Apple caught up to about where we were six months ago, which is going to be good enough for a lot of people.

[![Practical Agents with Donny Wals](https://i.ytimg.com/vi/1vOBfkxAHfY/maxresdefault.jpg)](https://brightdigit.com/episodes/210-practical-agents-with-donny-wals)

## Practical Agents

[Donny Wals](https://www.donnywals.com) returned recently on **[Episode 210 — Practical Agents with Donny Wals](https://brightdigit.com/episodes/210-practical-agents-with-donny-wals/)** and talked about what a year of *living it* looks like. Donny has been running agents daily, and he's blunt about the trade-off. The code writes itself faster:

> I'm mostly less concerned about repetitive code and boring stuff.

But reviewing it is the tax you pay for that speed:

> Reviewing them is more tedious. It's harder. It takes longer if we want to do it correctly — and almost every time there's a subtle bug.

## My one takeaway

What matters is the infrastructure around the work. AI has raised the floor on boilerplate to the point where it's almost free, but the judgment didn't go away, it just moved. **Reviewing, deciding what's worth building, knowing which bug the agent will quietly introduce — that's the work now, and it's still yours.**

🎙️ Two episodes, one conversation: **[Episode 208 with Joe](https://brightdigit.com/episodes/208-everyone-thinks-they-re-good-at-prompting-with-joe-fabisevich/)** for the framework, **[Episode 210 with Donny](https://brightdigit.com/episodes/210-practical-agents-with-donny-wals/)** for the year lived inside it. Listen to both back to back.

## Going deeper

If you're interested in learning my experiences check out:

- **Rebuilding MistKit with Claude Code** — the full story of redoing a 10-year-old CloudKit framework in three months, from Apple's docs to type-safe Swift: **[Part 1 — From CloudKit Docs to Type-Safe Swift](https://brightdigit.com/tutorials/rebuilding-mistkit-claude-code-part-1/)** and **[Part 2 — Real-World Lessons & Collaboration Patterns](https://brightdigit.com/tutorials/rebuilding-mistkit-claude-code-part-2/)**.
- **[Building SyntaxKit with AI](https://brightdigit.com/tutorials/syntaxkit-swift-code-generation/)** — a developer's journey building a Swift code-generation library with AI in the loop.
- **Vibe Coding** — beyond the talk up top, the [source repo](https://github.com/brightdigit/vibe-coding) has the workflow, prompts, and notes behind it.
- **Joe's blog, [build.ms](https://build.ms)** — if the quotes above landed, read him directly. [Being A 1.5-10x Developer](https://build.ms/2026/5/26/being-a-1-5-10x-developer/) on using agents to write *better* code, not just more of it, is a good place to start.

## If your team is wrestling with this

This is exactly what I'm running free 30-minute consults on right now — where AI tooling genuinely helps in a Swift codebase, and where it's a trap. No funnel, no pitch:

**[zcal.co/leogdion/consultation](https://zcal.co/leogdion/consultation)**

Or just hit reply and tell me how AI is (or isn't) showing up in your work — I'm collecting honest field reports, and I read every one.

Happy building!

— Leo

---

*Leo Dion · BrightDigit · [empowerapps.show](https://www.empowerapps.show) · [@brightdigit](https://twitter.com/brightdigit) · [YouTube](https://youtube.com/c/BrightdigitLLC) · leogdion@brightdigit.com*