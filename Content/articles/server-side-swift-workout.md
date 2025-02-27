---
title: How Does Server Side Swift Workout in the Real World?
date: 2025-05-09 00:00
description: Discover how an app evolved from a gaming heart rate monitor to a full-stack Swift fitness platform, exploring real-world challenges in authentication, WebSockets, and deployment.
featuredImage: /media/articles/server-side-swift-workout/featured-image.webp
---

In 2018, I attended the [try! Swift conference in New York](https://www.tryswift.co/events/2018/nyc/), where I participated in a workshop titled "Build a Cloud Native Swift App." 

![Try! Swift Kitura Workshop](/media/articles/server-side-swift-workout/tryswift-2018.webp)

At the time, Swift was primarily known as an iOS development language, so the concept of using it for cloud applications seemed unusual. This workshop introduced me to Kitura, but it was when I discovered [Vapor](https://vapor.codes) that everything clicked - I found it was fast, simple, and leveraged all of Swift's advantages.

## The Birth of Heartwitch

As a Nintendo Switch enthusiast who enjoys working out while gaming, I noticed something interesting in the speedrunning community - streamers often display their heart rate during runs. 

> youtube https://www.youtube.com/watch?v=Khu9BB2g4Ks

This observation sparked an idea: **what if we could create a system to livestream heart rate data in real-time?**

The initial implementation was straightforward:

1. Collect heart rate data through HealthKit
2. Send data to a Vapor server via POST requests
3. Transmit data to browsers through WebSockets
4. Display the heart rate overlay using OBS for streaming

I named this project [Heartwitch](https://heartwitch.app/#/) (a name I'd later reconsider), allowing streamers to share their heart rate data during gaming sessions.

## The Pandemic Pivot

In early 2020, the pandemic transformed how people approach fitness. As gyms closed and home workouts became the norm, I received an interesting email from Chris, who saw potential in adapting Heartwitch's technology for fitness instruction. The idea was compelling: help instructors monitor students' heart rates during remote classes, or allow instructors to share their own metrics while teaching.

> youtube https://youtu.be/dFmpD0yFP6Q

## Enter [gBeat](https://gbeat.com)

This pivot led to the creation of [gBeat](https://gbeat.com), a comprehensive fitness streaming platform. The core functionality includes:

- Real-time heart rate monitoring
- Instructor-student connectivity
- Automated workout session management
- Cross-platform compatibility
- Integration with various fitness platforms

### Why Server-Side Swift?

Choosing Swift for both client and server offered several advantages:

1. **Code Sharing**: Common models, networking code, and business logic can be shared between iOS, watchOS, and server components
2. **Type Safety**: End-to-end type safety across the entire stack
3. **Familiar Tooling**: Using Xcode and Swift Package Manager throughout the project
4. **Performance**: Swift's strong performance characteristics on both client and server
5. **Apple Ecosystem Integration**: Seamless integration with HealthKit, Push Notifications, and Sign in with Apple

## Architecture Overview

gBeat's architecture consists of several key components:

<img src="/media/articles/server-side-swift-workout/communication-diagram.svg" class="full-size" />


**The server handles:**
- Authentication and session management
- Real-time data streaming via WebSockets
- Push notification distribution
- Workout session coordination

**The client side manages:**
- HealthKit integration
- Local workout tracking
- UI/UX implementation
- Real-time data synchronization

> youtube https://www.youtube.com/watch?v=4iB8s2fEmYc

## Looking Forward

The journey from a simple gaming stream overlay to a full-featured fitness platform shows how Server-Side Swift can scale from hobby projects to production applications. In [the next post](/tutorials/full-stack-sign-in-with-apple/), we'll dive deeper into the technical implementation of authentication using sign in with apple and development challenges.