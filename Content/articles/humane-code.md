---
title: What is Humane Code?
date: 2023-10-10 00:00
description: What is humane code? humane code is a way of developing software that is empathetic and considerate those who will use and maintain your code in the future
featuredImage: /media/articles/humane-code/featured-image.webp
subscriptionCTA: I’m constantly trying to stay current on the latest developments in the Swift and iOS space, find other developers sharing their great ideas, and then share everything I learn in my newsletter, which I publish every month or so.
---

Writing code with future developers in mind is generally a good practice. It usually produces code that is easy to understand, cheap to maintain, better documented and has a longer lifespan than code written purely for a machine or reactive needs.

**But humane code takes this further.** It considers the everyday struggles and limitations that we all experience and the ways that our brains can, on some days, be really hard to use. When considering these realities, we choose to have empathy and kindness for other developers and ourselves.

This article is for senior developers, team leads, and managers who are invested in more deeply supporting their developers. Humane code is also an excellent tool for leaders who want to maintain good morale and employee retention.


I am covering what humane code is, its benefits, and good habits and practices for creating an environment that best supports developing it.

## What is Humane Code?

Humane code appears to have been first coined by Danish-based software architect Mark Seemann in his book [Code That Fits In Your Head](https://www.amazon.com/Code-That-Fits-Your-Head/dp/0137464401). The book is essentially a guide to reducing code complexity and building software at a sustainable, human pace.

**At its core, humane code is based on the idea that code is a conversation.** This conversation is between you as the developer writing it, a future version of yourself who will need to review and explain it, and other developers who will need to use and maintain what you create.

Ensuring that your code is readable means ensuring it communicates what is needed and expected by people in the future. It’s also a guide to avoiding the pitfall of fixating on the cleverest solution to our present challenges if that solution isn’t easy to explain. **If it can’t be communicated straightforwardly, it’s probably not sustainable.**

> youtube https://www.youtube.com/watch?v=YVrHPCZnC50

## Why is Humane Code Important?

As developers, we often try too hard to write code that works quickly or shows off cool features or optimization we’re excited about – I’m guilty of this, too. 😁 It looks impressive and wows managers and senior executives when you first demo it.

The problem is that those **same managers and executives will also be stressing out years later when they realize what a pain it is to work with when bugs need to be fixed, features need to be added, or maintenance needs to be done on the codebase.**

**Code that is easy to maintain and understand is ultimately more profitable and delivers long-term value to a company.**


## Good Habits for Creating Humane Code


### Make sure things are broken down appropriately

Having long, complex functions in our code isn’t necessarily bad, but as a general rule, the longer the function, the less readable it is.

The main reason this is so is because of the limitations of the human brain, particularly our short-term working memory. 

You probably recognize that when we’re coding a specific function, we usually have a _list_ of things that you need to hold in your head while you’re working on it – acceptance criteria, relevant dependencies, and a vision of what we want the code to look like when it’s complete. This is opposed to long-term memory, which is more akin to the habits, practices and things we’ve learned from years of programming.

And there is a limit to how much you can hold in your brain at any time. Seemann, in his book, cites that we can hold anywhere from 4-7 bits of information in our minds at once, but that heavily depends on what condition our mind is in that day.

It also fluctuates depending on how much attention and focus we have available. Anything that distracts you reduces this, as well as various factors related to our well-being, including whether:

* you had enough sleep last night
* you are hungry or thirsty
* the chair and desk you’re using are comfortable
* the room temperature is comfortable

And even more abstract things like if you have harmony within your relationships with team members or family.

![/media/articles/humane-code/student-not-paying-attention-2022-03-04-01-45-16-utc.webp](/media/articles/humane-code/student-not-paying-attention-2022-03-04-01-45-16-utc.webp)

All this to say, if any of these things are dragging on our attention, it translates into how we work with code and how much we need to hold in our minds to get into it and understand it enough to achieve whatever we’re on. This means that even under optimal conditions, having to pause and parse old code to understand will usually cause us to lose the context we have for the new feature we’re working on.

A good starting point is to break types down, including making each type and extension in the code its own separate file, and each file shouldn't be so long that it’s hard to hold its entire context in your mind. It is also a good idea to ensure consistent style and formatting throughout your entire code base – tools like [SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) can help you by automating and enforcing the conventions you create.

Related to this are the concepts of [microapps architecture](https://brightdigit.com/articles/microapps-architecture/), [TDD with Swift](https://brightdigit.com/episodes/093-test-driven-development-in-swift-with-gio-lodi/) and [good principles of iOS and Swift architecture](https://brightdigit.com/articles/ios-software-architecture/), which offer their own complementary ideas and concepts.


### Use descriptive naming and comments

When naming your databases, methods and classes, take a little time to consider calling them something descriptive so that you can be confident your future self or another person will understand what it is.

And while some argue that [good code doesn’t require comments](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882), if we’re being realistic, that will be the case when we’re 100% on top of our game. But few of our work days are that perfect – most days, we usually have something that’s drawing away our attention, making perfection an unreasonably high bar to clear day in and day out.

![/media/articles/humane-code/syndikit-docc-getting-started.webp](/media/articles/humane-code/syndikit-docc-getting-started.webp)

**While comments may not be needed, they can be really helpful for adding context to your code when they’re done thoughtfully and without creating too much ‘noise.’ **Take advantage of [Swift’s DocC native comment system](https://www.hackingwithswift.com/articles/238/how-to-document-your-project-with-docc). It’s easy to use, looks great, and ensures future developers can understand.


### Code reviews

The code review process is an essential part of humane development. It guarantees that somebody is looking at your code without the context that you had when you developed a feature and asking the questions needed to understand it.

> transistor https://share.transistor.fm/s/99f236b1

It’s a great way to combat the problem of being “too close” to the code you’ve written. After enough time, you often can’t see obvious errors or missing context because, over time, you naturally become blind to these details because they were embedded into the way you thought about the code as you were writing.


### Make your code accessible

Traditionally, when we’re talking about accessible code, we’re usually thinking about the end user and their limitations. But accessible code also includes making sure your code is accessible to other developers.

As we covered earlier, our working memory is highly susceptible to our environment and general mood – sleep, food, or even if we’re just a bit grumpy one day, it can mean our neurons aren’t firing as well as they could be.

But there’s also a range of more long-lasting conditions that someone can experience or live with that make working with code even harder. These range from executive function disorders like [ADHD](https://stackoverflow.blog/2023/02/19/developer-with-adhd-youre-not-alone/), autism and OCD; learning disorders like [dyslexia](https://www.bcs.org/articles-opinion-and-research/why-dyslexics-make-good-coders/) and dyscalculia; to physical limitations and disabilities, including blindness, deafness, and living without the use of a limb or having complete motor control.

**Accessibility is ultimately about recognizing that humans and their brains are imperfect, and because of that, making it as easy to understand as possible and ensuring your code is not more cognitively taxing than needed.**

This can be hard, especially if these limitations are not part of your own day-to-day life, but it can be figured out early if you make a point of asking questions at the [system design stage of app development](/articles/mobile-system-design/).


### Keep Your Logic Simple with Cyclomatic Complexity

We covered above how useful it is to keep functions small; there’s an additional element to keep in mind on the path of humane development – limiting [cyclomatic complexity](https://www.ibm.com/docs/en/raa/6.1?topic=metrics-cyclomatic-complexity).

Despite its name, cyclomatic complexity is pretty easy to understand – it measures all the paths you can take through a piece of code with a given function. The higher the cyclomatic complexity, the more paths there are and the more decisions that need to be made.

[Jill Scott on EmpowerApps](/episodes/137-humane-development-with-jill-scott/) does a great job explaining this, and I agree that’s an excellent way to measure to tell where you might want to look to simplify your logic. However, as Jill points out, it’s not perfect – a high complexity-rated piece of code might still be readable and accessible.

> transistor https://share.transistor.fm/s/2f6716c9

## A Special Thanks to Jill Scott

A big thank you to Jill Scott for sharing her insights in my conversation with her on [EmpowerApps](https://brightdigit.com/episodes/137-humane-development-with-jill-scott/). Our discussion was foundational in helping me learn more about the concept of humane code and developing this article. If you haven’t already, I encourage you to listen, following Jill over on X (formerly Twitter) at [@Jilsco9](https://twitter.com/Jilsco9).