---
title: watchOS 10 - Your Apple Watch Is About To Grow Up
date: 2023-08-14 00:00
description: watchOS 10 could fundamentally change how we make apps for the Apple Watch, becoming a platform where you can build dedicated apps. Learn more…
featuredImage: /media/articles/watchos-10/Apple-WWDC23-watchOS-10-5up-230605.webp
---
watchOS 10 is a maturity milestone for the Apple Watch. If you’ve been on the fence about building a Watch app – now is the time to reevaluate.

Announced at [WWDC 2023](https://www.apple.com/uk/newsroom/2023/06/wwdc23-highlights/), with the full release expected in September, [watchOS 10 comes loaded with massive changes that will fundamentally shift how we make apps for the Apple Watch.](https://www.apple.com/newsroom/2023/06/introducing-watchos-10-a-milestone-update-for-apple-watch/)

We’re covering what the future of the Apple Watch likely holds and what the most important features to look for from Apple and watchOS 10.

## What is the future of Apple Watch apps?

Since the widespread adoption of Swift UI in 2020, developing apps for the Apple Watch has become significantly more manageable and enjoyable. With the new OS, we potentially see the end of the biggest barrier to creating complex, cost-effective Apple Watch apps, especially ‘watch-first’ apps.

Before now, Apple Watch apps have suffered from hardware limitations and a lack of consumer awareness about what’s available. At BrightDigit, we’ve been optimistic about the Apple Watch’s trajectory: first with [the health-related functionality first shipped with the Series 4](https://brightdigit.com/articles/new-apple-watch-4/); the leaps and bounds made with [the introduction of watchOS 6 and the Series 5](https://brightdigit.com/articles/2020-apple-watch/), and particularly with the ability [to build complications with SwiftUI in watchOS 7](https://brightdigit.com/articles/apple-watch-series-6/).

Battery limitations remain baked into how the Apple Watch runs – even after the introduction of low-power mode with watchOS 9 – causing your apps to lose network connectivity or shut down because they are suddenly ‘not doing anything.’

And while [Apple has gained the largest share of the smartwatch market](https://blog.gitnux.com/apple-watch-statistics/), it has been a relatively slow-growing part of the Apple App ecosystem, and most watch users are only using a minimal range of apps.

> transistor https://share.transistor.fm/s/191be908

**watchOS 10 is the first major release that could change that,** but work still needs to be done by the release of the Apple Watch Series 9 if that’s going to be realistic.

One of the biggest obstacles to this is that, at the time of writing, the App Store isn’t well-optimized for Apple Watch apps. They have recently added a dedicated _Apple Watch apps_ category within the App Store, but it’s challenging to use on the Apple Watch itself and buried right at the bottom of the page when looking for it on the iPhone. The result is difficulty in new Apple Watch apps getting noticed by users.


## What makes watchOS 10 different?

There are several changes that we can already see in watchOS 10’s beta release that amount to a major step in terms of usability and opportunities for Swift developers:

<a href="https://www.apple.com/newsroom/2023/06/introducing-watchos-10-a-milestone-update-for-apple-watch/">
<figure>
    <img class="icon" src="/media/articles/watchos-10/Weather.webp" />
</figure>
</a>

### Full Navigation

The watchOS 10 beta is showing some significant changes to user navigation. This includes new features like a vertical tap view, lists that are easy to scroll through, and a toolbar.

Getting these _right_ will be critical if Apple is serious about growing its market for the Apple Watch and encouraging existing users to buy the latest hardware.

Assuming Apple understands this perfectly well, we can look forward to these major improvements in user experience being included in the launch of watchOS 10. In turn this makes it far easier and attractive for independent developers and brands to create dedicated Apple Watch apps.

### A More _Glanceable_ Interface

This is perhaps the one change that everyone can get excited about. watchOS 10 is seeing a complete overhaul of the user interface, with a new grid-like design and focus on making it easy to get the information you want at a glance from various widgets.

<a href="https://www.apple.com/newsroom/2023/06/introducing-watchos-10-a-milestone-update-for-apple-watch/">
<figure>
    <img class="icon" src="/media/articles/watchos-10/Smart-Stack-Weather.webp" />
</figure>
</a>

### Smart Stack

Related to the new interface is the addition of a library of the most used/most important widgets, making it easy to create new interfaces quickly for simple Apple Watch apps. \
 \
This works similarly to the widget stack available on iOS and the Siri watch face, except now the entire library is accessible at all times from the watch face. It also _learns,_ offering up certain widgets first based on your user behavior. 

### Improved Debugging

Debugging on the Apple Watch up until now has been complicated and unreliable. With watchOS 10, it has improved enormously, making it uncomplicated when developing and testing new apps for the Watch.

And Several more minor but still great improvements, including

* NFC interactions between the Apple Watch and the iPhone
* Offline maps
* New APIs for velocity and acceleration data
* Bluetooth compatibility between the Apple Watch and popular digital cycling tools
* For travelers moving outside their reception areas, the Apple Watch now shows a waypoint marking where the user last had connectivity.
* A new Snoopy-themed watch face!

> youtube https://youtu.be/QL2xpDqBGxo

_A special thank you to fellow SwiftUI developer and product designer [Hidde van der Ploeg](https://www.linkedin.com/in/hiddevdploeg/). _I’ve chatted with Hidde [on EmpowerApps](https://brightdigit.com/episodes/153-arm-sling-for-apple-watch-developers-with-hidde-van-der-ploeg/), and he and I had a great conversation, sharing our excitement for watchOS 10 and the possibilities it could open up for us as developers.

<video autoplay loop muted width="720">

  <source src="/media/articles/watchos-10/watch-clip.mp4" type="video/webm" />

  <source src="/media/articles/watchos-10/watch-clip.mp4" type="video/mp4" />

  <iframe width="560" height="315" src="https://www.youtube.com/embed/aSpE98HxNrc?controls=0&amp;clip=UgkxQo79gkw_1TRldgf_bmYvlF_kf8gb8h0H&amp;clipt=EJ_QFxi86Bk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</video>

At BrightDigit, we’re already invested in building apps primarily for the Apple Watch. Most prominent of these are [Heartwitch](https://heartwitch.app/#/) and [gBeat](https://heartwitch.app/#/), which make use of the Watch’s health functionality for streamers and fitness trainers, respectively. We’ve also got more plans in store, which [you can learn about here](https://brightdigit.com/episodes/156-now-you-know-what-i-m-doing-this-summer/).


## If you want a Watch app, let’s talk!

I offer specialized Swift development consulting for organizations and agencies that want to build high-quality apps for the Apple ecosystem. If you’re looking for additional expertise or are planning to start developing a new Swift app this year, let’s talk. [**You can book a 30-minute consulting call with me right now and find out how I can help you.**](https://zcal.co/leogdion/consultation)
