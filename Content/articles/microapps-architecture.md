---
title: What are the benefits of microapps?
date: 2023-07-12 00:00
description: Microapps are a way of organizing your app’s functionality and related services. Break down the functionality you need into small modules, then assemble.
featuredImage: /media/articles/microapps-architecture/colorful-pieces-from-building-kit-for-children-on-2021-10-04-18-05-50-utc.webp
subscriptionCTA: If you want to learn more about the latest developments in mobile app development in the Apple and iOS space, sign up for my newsletter. I put it out once a month, including content and news from my work and what’s happening within the Swift development community.
---

Microapps have been gaining popularity in the last few years – increasingly, businesses find large, monolithic applications very difficult to maintain. Additionally, there has been a push to make apps mobile-friendly, which leads to a trend of applications that are flexible.

If you’re leading or managing the development and growth of large, complex apps, this article is meant to help you understand **the benefits, both business and technical, of microapp architecture** and how to decide whether it might be a good choice for your development needs.

> transistor https://share.transistor.fm/s/ff9b73a8

## What is microapp architecture?

Microapp architecture is the style of using smaller single-function apps to create larger, more complex apps.

The main principle is rather than building a single, large, monolithic app, you **break down the functionality you need into small, lightweight, self-contained modules and then assemble them as a larger app.** Microapps are a way of organizing the functionality of your app and its related services.

There’s also another term you’ll see related to this: microservices. **You can think of microservices as the same style of architecture but applied to the development of the backend of your app, while microapps usually mean we’re talking about your app’s frontend and UI.**

As we’re mostly interested in microapps for apps in the iOS ecosystem, we’re going to be primarily focusing on [how to use this style in Swift](https://swiftwithmajid.com/2022/01/12/microapps-architecture-in-swift-spm-basics/) for mobile applications, but the principles of microapp architecture can be used for just about any platform or programming language.


<img alt="Putting the puzzle together" class="full-size" src="/media/articles/microapps-architecture/Isometric businessman assembling last piece of jigsaw puzzle.webp" width="410" height="400" />

## What are microapps good for?

With apps I’ve developed for both my clients and myself, I have come to really like using microapps. My apps have gotten pretty large – microapps have been a great way to make the codebases easier to maintain, change, and add new functionality to.

![Backup Your Data](/media/articles/microapps-architecture/Bushel-MicroApps.webp)

### Build, test and change your app’s functionality quickly

The biggest and most obvious benefit of microapps is that when your entire app is broken down into single-function parts, building each part, testing it, and adjusting it as needed can be done very rapidly. 

This is a bonus if you’re already using short development cycles or sprints as part of using frameworks like [Scrum](https://www.scrum.org/resources/what-scrum-module), [Kanban](https://www.agilealliance.org/glossary/kanban/), or a [continuous integration](https://brightdigit.com/articles/ios-continuous-integration-avoid-merge-hell/) approach to development. Using microapps architecture should mean both minimal compile-time needed for everything and minimal operational and merge conflicts, as modules are independent of each other.

This also makes microapp architecture a good choice if you’re developing an app that:

* Requires **a lot of small, discrete tasks embedded in the UI**.
* You **plan to scale** or add lots of additional functionality over its lifecycle.

### Do One Thing Really Really Well

If you’re going to take full advantage of having fine control over each function within your app’s UI, microapps make it possible to tailor each module to your users’ needs and overall make your user experience (UX) to best it can possibly be once the entire app is assembled.

Essentially, the app your user sees [_wraps around_ all the microapp](https://increment.com/mobile/microapps-architecture/)  modules, bringing everything together into a single, coherent UX.  Ideally, you’re using some kind of [UI design system](https://www.untitledui.com/blog/what-is-a-design-system), but even if you’re not, you should have a dedicated library to make it easy to import modules and maintain a consistent look and feel across all your microapps.

On large multi-team projects, this style can also be used for building internal tools that are made for them, built only for working on a specific feature or component.

For iOS specifically, using [Swift Package Manager](https://swiftwithmajid.com/2022/01/12/microapps-architecture-in-swift-spm-basics/) is a great tool for using microapp architecture, as it easily allows you to modularize all your app’s functionality.

> youtube https://www.youtube.com/watch?v=OM9jbAbUXZ0

### Keep it all internal

Microapp architecture, because of its modularity, allows you to bring better API design to your development projects. This approach is essentially designed to remove the need for inter-team dependencies.

You should be able to deliver even single modules to quality assurance, who are able to verify a given feature works and meets requirements without the need to wait for other teams to finish the development of a given module.

<img alt="Putting the puzzle together" class="full-size" src="/media/articles/microapps-architecture/business-people-building.webp" width="281" height="300" />

## What are the challenges of implementing microapps?

While microapp architecture is an excellent choice for an enormous number of complex apps, they are not a panacea. There are a few contexts where it may not be the best approach or where you’ll only get to realize a small amount of its potential:


### Difficult to integrate with existing systems

Microapp architecture, in a way, assumes that either you’re developing a new greenfield app or you’re ready and willing to rethink completely how your developers approach complex app development and who has control and ownership of the app’s features.

On a business level, **microapp architecture gives each development team complete ownership of the modules they’re working on,** independent of other parts of the business. It is assumed that the business, as an organization, is ready to give its teams that kind of autonomy.

Because everything is broken down into small parts, this approach will likely make it hard to use existing systems that aren’t designed this way. On a technical level, microapp architecture doesn’t mean “the same app we had before, but now split up into 20 different modules,” but an approach that helps you refine and focus on a set of features being the most user-friendly they can be.


### Specific Use Case instead of All-Purpose

If you’re trying to stuff all your existing offerings into a single app, **microapp architecture won’t save your falling user adoption rate – it will only help you run into the same obstacle faster.** Undertaking a redevelopment of a large, complex app using microapps requires proper planning, training and management of the development process to handle it.

Because microapp architecture is built around breaking things down into either single-function modules or modules with a limited number of related functions, it is an excellent solution to build around specific use cases.

What it is not great at is handling a wide array of unrelated purposes, where you end up with a ton of modules that are only going to be used for one thing, which kind of defeats the efficiencies this approach is designed to give you.


### How small is too small? 

If you’ve got this far, you might think you should break every function or set of functions down into its own module. While it’s great to decouple things, it can add extra complexity to your project. While there isn’t a hard rule for this, some things probably don’t need to be completely modularized.
Given that the development team has ownership of each module, **it’s best to make sure there is a conversation within the team about how they’re doing to split and extract all the functionality they need to deliver.**

> transistor https://share.transistor.fm/s/e07bf6ba

## How to figure out if microapps are a good choice for you

To sum things up, if you’re still wondering where a microapp approach would be a big help in your development process, there are a few questions you can ask yourself and your team – if you can answer ‘yes’ to most of them, then it’s likely a good choice;

1. **Do you know what specific user challenges you want to solve** that fit the strengths of microapp architecture – i.e. can you break it down into related functional modules?
2. Are you and your client **prepared for short development cycles?** Do all stakeholders have realistic expectations about what that’s going to look like?
3. How much do you need **task-specific applications?**
4. Is it important for you to **constantly be able to modify your app?** If you don’t think your app will change much after full release, microapps may be less helpful.
5. Does **the app match business objectives,** not just the needs of the development team?

> youtube https://www.youtube.com/watch?v=XRVO43j1ogQ

## Special Thanks to Majid Jabrayilov and Gio Lodi

I want to give a big thank you to [Majid](https://twitter.com/mecid), who I recently had [back on EmpowerApps](https://brightdigit.com/episodes/123-microapps-architecture-with-majid-jabrayilov/). Talking with him was an inspiration and guide in putting this article together. He has some excellent content [on his website](https://swiftwithmajid.com) about how to use microapps with Swift, which is a great resource if you’re looking to get started. I’d also like to thank Gio Lodi, who wrote an[ excellent introduction to microapps for developers](https://increment.com/mobile/microapps-architecture/) if you’re interested.
