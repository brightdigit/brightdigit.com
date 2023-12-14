---
title: Bushel of an App - Making Cider from Apples
date: 2023-12-19 00:00
description: How much time should you spend on marketing your app? The answer seems to always be more.
featuredImage: /media/articles/bushel-launch/GitLab.IssueBoard.webp
---

How much time should you spend on marketing your app? The answer seems to always be more.

It is very easy for me to sink days into Xcode worry about a bug that users may or may not notice  as opposed to letting people out there even know about my app. 

---

* [Part 1 - From Seed of an Idea](/articles/bushel-launch-part-1)
* [Part 2 - Building the Crust](/articles/bushel-launch-part-2)
* [Part 3 -  Design, Architecture, and Automation](/articles/bushel-launch-part-3)
* _Part 4 -  Making Cider from Apples_

---

* **[Obligatory AI Section](#obligatory-ai-section)**
* **[What's Next](#whats-next)**
* **[Thank You](#thank-you)**

---

One of the first steps when starting **[Bushel](https://getbushel.app)** was to create a website that was easily updatable and an email list for future users (and beta testers) of the app. For the email list, I used [formspree](https://formspree.io) until I had TestFlight up and ready. For building the website I went with [Eleventy](https://www.11ty.dev) which I’ve grown to love for its simplicity and expandability.

Additionally I setup a Slack for beta testers as builds began to go out in the public. This was a big help getting **[Bushel](https://getbushel.app)** into people’s actual hands and hearing their reactions and questions.

## Obligatory AI Section

A blog post can’t be finished until I mention AI and in particular ChatGPT. Did I use it for Bushel? yes! And... No!

Code help from ChatGPT was not great. For _simple_ algorithms, that is something which is easily explainable and generic (not Apple API specific); it was fine. However where it really falls short is specialized niche Apple APIs that have changed or been updated over the years … and that’s a lot. 

For instance in the case of measuring disk space for a directory it would give contradictory code with parameters or flags which don’t exist. (Regardless I can’t measure the size of a `NSFileVersion so the math is useless.) However some pieces of code were very help or at the least good starting points for me to work with. What makes right now for good instances are ChatGPT prompts which:

- are formulaic in input and output
  - Turn this into a ViewModifier
  - Make a Swift…case statement which returns SFSymbols for Virtual Machine State
  - Turn this into a `stringdict`
- Common enough to have been part of the Model (i.e. SwiftUI)

Where ChatGPT was most helpful was in **copywriting** (i.e. marketing and application text). 

**As someone who is developing the app, it can be very difficult to come up with the right words to explain something just as it would be for a fish to describe the water they are swimming in.**

ChatGPT gave me the ability to concisely explain what I am trying to convey to user. While ChatGPT may hallucinate with certain answers I have the ability to redo my prompts, clarify with further questions, or ask for more answers or examples. This also means I’ve been able to build a lengthy _dialog_ with ChatGPT so it can learn about the app as I continue to ask questions and prompts for more text in marketing material, application copy, or AppStore requirements.

**This is big help for me as a developer who may have a difficult context switching to being copywriter on occasion.**

## What's Next?

My hope is that `1.0.0` is a foundation for building a future for Bushel. I am sure there will be bugs but new features are essential to the future of **[Bushel](https://getbushel.app)** so here's a few:

### Separate Command Line Tool

This would be a separate command line tool to manage files used by **[Bushel](https://getbushel.app)** such as machines and libraries. Part of that would also include...

### Partial Open Sourcing 

Open sourcing section of the app which are used by a separate command line tool would allow for easy installation and setup. As well as enourage outside expansion, perhaps via...

### ExtensionKit 

The possibility of allowing developers to extend **[Bushel](https://getbushel.app)** in certain spots for custom behavior and integration. Additionally it can encourage ...

### More Integrations

More integrations to other VM systems and _hubs_. The work by the [Cilicon](https://github.com/traderepublic/Cilicon) and [Tart](https://tart.run) teams are very interesting as well as integrating other online repositories for restore images such as [IPSW](http://ipsw.me).

### Bushel Service

There are several parts of the service which I need to research:

- **XPC** _for better handling of **[Bushel](https://getbushel.app)** as a service_
- **Vapor** _for remote and local calls to the service_
- **Background Tasks** _for monitor updates to files outside of Bushel_
- **Menu Icon** _for easy access outside the app windows_

Each of these would be a slow integration into **[Bushel](https://getbushel.app)** in order to ensure a stable interface.

<figure>
  <img src="/media/articles/bushel-launch/Hub-AppStore.webp" class="contained">
  <figcaption>Hub Window from Bushel</figcaption>
</figure>

### UI Updates

Lots of the UI could use updates and an improved design. 
There are things I did not get to complete in this version which I had in the initial designs so including these would be great. I also hope to use more notifications for longer processes which would be helpful to the user. 

### Screenshots, Videos, and SharePlay

Being inspired by _RocketSim_ I want to include more features for taking screenshots, videos but also shared somehow via some API (SharePlay, streaming, or any method available).

### Bushel Guest Tools

A non-sandbox app, you'd install on your VM to give everything you need to reliable test and debug an application on the VM. This would also include better integrations with **[Bushel](https://getbushel.app)** for more customization of software on the VM.

## Thank You!

Lastly I want thank all of you for reading this article and learning about the process of building **[Bushel](https://getbushel.app)** since day one. With your support you've help make this app a reality. I am looking forward to continue building on top of it in 2024. Feel free to reach out to me on social media if you have any questions, comments, or feature requests.
