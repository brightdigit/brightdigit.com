---
title: Bushel of an App - From Seed of an Idea
date: 2023-12-14 00:00
description: Unfortunately creating my own VM app seemed like a huge undertaking, how would I even get started?
featuredImage: /media/articles/bushel-launch/CreateMachine.webp
---

**There are benefits to developing on the Mac as opposed to iOS.** When I started getting into Mac developer it reminded me of how easy it is to develop on the same machine as the one you are testing on. Especially as someone who’s developed for the Apple Watch, **not dealing with deployment, remote debugging, etc… was a big advantage of the Mac.** 

However I did start to miss some of the benefits of the iOS simulator:

- The ability to easily start with a brand new iPhone every time. 
- To test different versions of the operating system. 

I did not have these benefits as a macOS developer.

When I’d develop a Mac app and a user would notify me of a bug, I had no way to test it - and replicate their environment. 

---

* _Part 1 -  From Seed of an Idea_
* [Part 2 - Building the Crust](/articles/bushel-launch-part-2)
* [Part 3 - Design, Architecture, and Automation](/articles/bushel-launch-part-3)
* [Part 4 - Making Cider from Apples](/articles/bushel-launch-part-4)

---

- **[Getting Started](#getting-started)**
- **[What am I doing?](#what-am-I-doing)**
- **[Designing around a sandbox](#sandbox-design)**
- **[Document Based?](#document-based)**

---

For instance, when I forgot the different ways decimal points are used and _assumed_ one particular way. I didn’t have an easy way at the time to test my app using that localization. Another instance is when a _developer_ setup script needs to be created. How do I test when the developer doesn’t have _Homebrew_, _Git_, or _Xcode_ installed and deal with those scenarios?

Besides that, the iOS simulator has a solid set of tools with `simctl` as well as more powerful dev tools like [RocketSim by Antoine van der Lee](https://www.rocketsim.app).

There’s apps like VirtualBox and Parallels however those app aren’t targeted to Mac developers like myself. **I wanted something to have that Apple feel while being a powerful developer tool.**

Unfortunately creating my own VM app seemed like a huge undertaking, how would I even get started?

![Welcome Screen from Bushel](/media/articles/bushel-launch/Welcome.webp)

<a id="getting-started"></a>
## Getting Started

There had been [the Hypervisor framework][https://developer.apple.com/documentation/hypervisor] for quite some time however it’s a C-based API and lacks the Swift-ness I had grown accustomed to. However in 2020, Apple released [the Virtualization framework][https://developer.apple.com/documentation/virtualization] which gave developers a Swift interface for creating and running their own macOS VMs. 

This meant I can at least try to create an VM app for macOS Developers. 

[![Virtualization Tutorial](/media/articles/bushel-launch/Virtualization.webp)](https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon)

[Apple has a great sample project](https://developer.apple.com/documentation/virtualization/running_macos_in_a_virtual_machine_on_apple_silicon) which shows you how to easily setup a new VM. The challenges will be creating a new Sandboxed app which integrates SwiftUI with the Virtualization framework.

**Starting the summer of 2022,** I began work on designing **[Bushel](https://getbushel.app)**. How can I create an intuitive yet functional app for developers? 

<figure>
  <img  class="full-size" src="/media/articles/bushel-launch/ImageList.webp" />
  <figcaption>Sketch of the list of macOS Restore Images</figcaption>
</figure>

<a id="what-am-I-doing"></a>
## What am I doing?

**The biggest challenge came from using SwiftUI and being able to keep record of existing images and machines.** The Virtualization framework uses restore images as the basis for setting up (i.e. installing the OS for) a brand new virtual machine. If you’ve ever had to restore an iOS device, you probably are familiar with these ipsw files. Since the advent of Apple Silicon Macs, this has followed that same pattern.

I did not want to employ Core Data since I didn't want to maintain something with a technology which was nearing a Swift-y refresh. I also wanted to take advantage of the latest APIs in SwiftUI while supporting the oldest OS I can. The result was using UserDefaults to store records about the machines and images used while supporting macOS Monterey 12 and up. 

This would be become a challenge going forward with some serious lessons learned.


<figure>
 <img  class="full-size" src="/media/articles/bushel-launch/Machine.webp" />
 <figcaption>My first sketch of the Machine View</figcaption>
</figure>

<a id="sandbox-design"></a>
## Designing around a sandbox

Firstly with a sandboxed app I need a way to keep record of _bookmarks_ for each file uses. I also wanted to take advantage of the new Document-Based capabilities in SwiftUI. 

**Inspired by the work I do Final Cut Pro, I created a Library for restore images.** This would contain the easily accessible metadata for each image while also ensuring it was a file accessible by Bushel. In most cases, users would only need one Library on their host machine but supporting multiple wouldn’t hurt either. Since these images were between 12-15 GB I wanted to allow users to specify where they were located on their disk as opposed to storing them inside the app’s configuration. 

<figure>
 <img  class="full-size" src="/media/articles/bushel-launch/CreateMachine.webp" />
 <figcaption>My first sketch of the Machine Configuration</figcaption>
</figure>

<a id="document-based"></a>
## Document-Based?

Despite using the latest technologies, **the Document-Based SwiftUI API ended up becoming more hinderance rather than a benefit**. The Document-Based SwiftUI API was more tailored for smaller files of which the developer had greater control over. In the case of **[Bushel](https://getbushel.app)**Libraries and more so Machines, there are components which are very large but more so I only had control over through the Virtualization framework. These are files like the virtual machine identifier, virtual machine disk and more. Additionally maintaining records of created machines and libraries in UserDefaults along with Combine became a mess. 

Lastly **supporting Monterey meant I lost a lot of the new APIs available to me** regarding window management in macOS. macOS SwiftUI has been less of a priority for Apple and so I was creating even more challenges for myself by supporting an older OS.

As more work came in **[Bushel](https://getbushel.app)**took a back seat. However [with WWDC came new opportunities for a serious refresh of Bushel.](/articles/bushel-launch-part-2)
