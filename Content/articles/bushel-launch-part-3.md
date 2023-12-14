---
title: Bushel of an App - Design, Architecture, and Automation
date: 2023-12-18 00:00
description: I am the kind of developer who prefers things in the smallest pieces as possible - small files, small types, small functions, small targets, etc…
featuredImage: /media/articles/bushel-launch/Microapps-Targets-XcodeGen.webp
---

Much of the design for the app, mostly came from the apps I use that are designed well within macOS. In other words, **they used the patterns that a developer like myself are familiar and comfortable with.** These include:

- [RocketSim](https://www.rocketsim.app)
- [Pixelmator](https://www.pixelmator.com)
- Xcode
- Simulator
- [Final Cut Pro](https://www.apple.com/final-cut-pro/)

I tried to avoid in this version any other Virtual Machine app (except for Docker I suppose which I use nearly all the time). This meant I did not use Parallels or VirtualBox as well as the highly acclaimed [VirtualBuddy by Guilherme Rambo](https://github.com/insidegui/VirtualBuddy).

---

* [Part 1 - From Seed of an Idea](/articles/bushel-launch-part-1)
* [Part 2 - Building the Crust](/articles/bushel-launch-part-2)
* _Part 3 -  Design, Architecture, and Automation_
* [Part 4 - Making Cider from Apples](/articles/bushel-launch-part-4)

---

* **[Microapps](#microapps)**
* **[PackageDSL](#packagedsl)**
* **[FelinePine](#felinepine)**
* **[Murray](#murray)**
* **[XcodeGen](#xcodegen)**
* **[GitLab CI](#gitlab-ci)**
* **[Fastlane](#fastlane)**
* **[If a tree falls in the forest...](#if-a-tree-falls-in-the-forest)**

---

The biggest design restriction was that **it needed to play along the rules of a Sandboxed app.** Therefore **every file used in the app must go through a file dialog of some sort and that the app must save the bookmark data for the file.** In my case in the Swift Data database. Sandboxing would also become an issue as I used a Microapps architecture for the application. 

![Machine Window from Bushel](/media/articles/bushel-launch/Bushel-Machine.webp)

<a id="microapps"></a>
## Microapps

[Microapps architecture means I would create separate apps for each part of the application.](https://brightdigit.com/articles/microapps-architecture/) Additionally Swift Package was used for nearly all the code in the application. The exception being one code file which is the entry point for the application:

```swift
import SwiftUI
import BushelApp

@main
struct BushelApp: Application {
  @Environment(\.scenePhase) var scenePhase
}
```

The _Microapp_ parts of the application are:

- Machines
- Libraries
- Hubs
- Market
- Onboarding
- Settings
- Welcome

> transistor https://share.transistor.fm/s/ff9b73a8

It was also important that specialized Apple components or anything shared accross these parts were in separate targets. This includes: 

- SwiftUI, Observable and other UI Components 
- Database (SwiftData Models)
- Shared SwiftUI Environment Variables
- Other specialized Apple components (such as StoreKit)
- All Virtualization framework code

The app was built with the intention of allow other virtual machine systems to be integrated in the future.  On top of the additional _supporting or core_ targets, this means there are currently 52 targets in the **[Bushel](https://getbushel.app)** Swift Package.
  
<figure>
  <img src="/media/articles/bushel-launch/Xcode-Packages.webp" class="contained">
  <figcaption>All the Swift Package Targets... and the <em>one</em> Application code file</figcaption>
</figure>

In order to facilitate either building of microapps, I used [XcodeGen](https://github.com/yonaskolb/XcodeGen) to create a project for each target.

<figure>
  <img src="/media/articles/bushel-launch/Microapps-Targets-XcodeGen.webp">
  <figcaption>Target setup in the XcodeGen project.yml file.</figcaption>
</figure>

This worked really well until I started using bookmark urls from Sandboxing. Once I did that, I no longer had access to the same urls and the micro apps would crash. (Humorously there were no issues with sharing the Swift Data database.)

Otherwise the use of MicroApps has made it much easier to keep concepts and sections of the app separated. **I am the kind of developer who prefers things in the smallest pieces as possible: small files, small types, small functions, small targets, etc…**

However it made the Package.swift file quite cumbersome to manage. This is where PackageDSL came in. 

<a id="packagedsl"></a>
## PackageDSL

I was inspired by the work of Josh Holtz and [his DeckUI library](https://github.com/joshdholtz/DeckUI) to create a (SwiftUI-like) DSL for Swift packages. [This was the origin for PackageDSL.](https://github.com/brightdigit/PackageDSL) This would allow for:

- individual files per target, dependency etc… ensuring small files
- removal of boilerplate code
- encourage best practices for Swift packages
- easy to understand organization

<figure>
  <img src="/media/articles/bushel-launch/PackageDSL.Folder.webp">
  <figcaption>New Swift Package setup using PackageDSL.</figcaption>
</figure>

Now it became much easier and faster for me to create new targets. And with smaller targets comes:

- improved build speed
- improved separate of concerns (and testing)
- easy to maintain structure

<figure>
  <img src="/media/articles/bushel-launch/PackageDSL.webp" class="contained">
  <figcaption>Better organized Swift Package setup with PackageDSL.</figcaption>
</figure>

The only requirement is some boilerplate support files and a simple bash script to concatenate all the files in the directory I store my Package metadata into so it will create a usable Package.swift file.

```bash
#!/bin/sh

# package.sh

echo "⚙️  Generating package..."

if [ -z "$SRCROOT" ]; then
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  PACKAGE_DIR="${SCRIPT_DIR}/../Packages/BushelKit"
else
  PACKAGE_DIR="${SRCROOT}/Packages/BushelKit" 	
fi

cd $PACKAGE_DIR
echo "// swift-tools-version: 5.9" > Package.swift
cat Package/Support/*.swift >> Package.swift
cat Package/Sources/**/*.swift >> Package.swift
cat Package/Sources/*.swift >> Package.swift
```

<a id="felinepine"></a>
## FelinePine

The only _outside_ library I used (and developed) was [FelinePine](https://github.com/brightdigit/FelinePine), a logging library I developed. FelinePine allows me to easily designate the category for each class I use. 

```swift
internal struct VirtualMachine: Loggable {
  internal typealias LoggingSystemType = BushelLogging

  // set the logging category for VirtualMachine to `.machine`
  internal static let loggingCategory: BushelLogging.Category = .machine
  
  func run () {
    // use the `.machine` logger to log "Starting Run"
    Self.logger.debug("Starting Run")
    ...
  }
  ...
}
```

I've been developing it off and on for a year and I think it could be fairly useful to folks in the community.

<a id="murray"></a>
## Murray

In Xcode, if you’ve ever created a new file in a Swift Package, you’ve probably had issues with the file name or content.

> youtube https://youtu.be/ZyQEuZzLDqU

This is where Murray comes in. As I talked about in [a previous episode](/episodes/168-we-have-all-the-heroes-with-stefano-mondino/), I used [Murray](https://github.com/synesthesia-it/Murray) for several templates including new Swift Package targets via PackageDSL:

```Stencil
//
// Bushel{{name|firstUppercase}}.swift
// Copyright (c) 2023 BrightDigit.
//

struct Bushel{{name|firstUppercase}}: Target {
  var dependencies: any Dependencies {
	BushelCore()
	BushelLogging()
  }
}
```

Or creating a new SwiftUI View:

```Stencil
//
// {{name|firstUppercase}}View.swift
// Copyright (c) 2023 BrightDigit.
//

#if canImport(SwiftUI)
  import SwiftUI

  struct {{name|firstUppercase}}View: View {    
    var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
  }

  #Preview {
    {{name|firstUppercase}}View()
  }
#endif
```

**As someone comfortable with the terminal, this makes it much easier for me to create entire new features in Bushel.** Additionally since it’s a Swift Package, there's no need to let Xcode know about the new file since package directories are automatically parsed. When I do need to make changes to Xcode projects that’s where XcodeGen comes in.

<a id="xcodegen"></a>
## XcodeGen

Using [XcodeGen](https://github.com/yonaskolb/XcodeGen) makes this an even better match since I can have XcodeGen run the PackageDSL script each time it creates a new Xcode project:

```yaml
name: Bushel
options:
  preGenCommand: ./Scripts/package.sh
...
```

[XcodeGen](https://github.com/yonaskolb/XcodeGen) really is the glue holding together the Swift Package, Xcode, and Fastlane. XcodeGen allows for simple repeatable creation of the Xcode projects for easy development. At some point I may transition to [Tuist](https://tuist.io), especially as [PackageDSL](https://github.com/brightdigit/PackageDSL) is so Swift dependent - I may as well transition from YAML to Swift but XcodeGen is working well for me.

Included are set of linting tools I use to optimize my applications code. In this case I am currently using mint and a bash script to lint my code at each build:


```
Faire/StringsLint@0.1.7
nicklockwood/SwiftFormat@0.51.13
realm/SwiftLint@0.41.0
```

With [XcodeGen](https://github.com/yonaskolb/XcodeGen), I have the option to set how strict my linting will be and can pass that into the Xcode build steps accordingly.

<a id="gitlab-ci"></a>
## GitLab CI

I have been using [GitLab](https://gitlab.com) for years on my private projects and have had very few issues with their CI setup. Purchasing a Mac mini for my CI has been a big advantage as well allowing me to regularly build and verify the builds of my applications.

With GitLab, I have been able to setup builds and testing on both macOS and Linux docker machines. The benefit of having targets separated really pays off on the Linux setup since much of my code-base isn’t built to be Apple-specific there I can test business logic quickly on Linux and then for higher priority build ensure they work on macOS. 

So while I can’t test `Observation` or `Virtualization`, I can test the base OS-agnostic function on Linux as well as iPhone Simulator if a developer didn’t want to install a Sonoma beta during development.

<a id="fastlane"></a>
## Fastlane

Most importantly [Fastlane](GitLab) was easily configured with the CI setup. At no point did I manually archive and upload to the App Store any builds. This meant all builds and metadata were deployed via Fastlane and Gitlab CI. Additionally `match` was used for storing and setting up certificates and provisioning profile making sharing the project much easier and worked really well with the XcodeGen setup. Lastly after every build was uploaded I used [`yq`](https://github.com/mikefarah/yq) to increment the build number in the XcodeGen project file ensuring I’ll never upload the same build number again.

<a id="if-a-tree-falls-in-the-forest"></a>
## If a tree falls in the forest...

It's really great to see an automated system quickly verify and deploy a build to TestFlight or to the AppStore. However it means nothing if no one is using are testing the app. Let's discuss [the marketing side, how AI fits in, and what's the future for Bushel.](/articles/bushel-launch-part-4)