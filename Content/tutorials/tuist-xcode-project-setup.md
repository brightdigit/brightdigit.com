---
title: Automating your Xcode Project
date: 2026-05-18 12:00
description: Before any CI/CD automation can run, you need a project structure worth
  automating. This part covers Xcode project generation with Tuist, keeping all real
  code in Swift Packages, and the package topologies that work for apps of every size.
tags: tuist, xcode, swift, ci-cd, tooling
featuredImage: /media/tutorials/tuist-xcode-project-setup/tuist-xcode-hero.webp
subscriptionCTA: Want to stay up-to-date with the latest Swift tooling and CI/CD
  tips? Sign up for the newsletter to get notified when new tutorials drop.
---

When creating an app, let’s think about we need to get started. At the top of your mind is the Xcode Project. The Xcode project is the backbone of your application. It contains various metadata, messaging, and build configuration of your application. Metadata would include bundle identifiers and permission text. Build configuration includes your targets which could be anything from the application itself, frameworks, and app extensions. The Xcode project is in a special proprietary format which for many is difficult to deal with both if you want to directly but most especially if you deal with version conflicts.

<!-- Why/Why not tuist -->

 This is where a tool which creates the Xcode project is most helpful. There’s 2 leading tools which I’d recommend: Xcodegen or Tuist. Xcodegen is great if you have a fairly simple app or minimal team structure. Xcodegen uses Yaml for its specification structure. The tool will take that yaml and convert it an Xcode project. Tuist is what I’d recommend in most any other case. Tuist uses Swift and is much more flexible for larger teams and applications. Tuist has a very robust community and support as well. In the end I’d highly recommend **not** committing Xcode projects to your code repository.

<!-- How to add tuist -->



# Using Tuist

You can begin using Tuist by running:

```
mise exec tuist -- tuist init
```

For my app Lumemo, a memo taking iPhone app for iOS 26 this is the Project.swift tuist created:

```swift
import ProjectDescription

let project = Project(
    name: "Lumemo",
    targets: [
        .target(
            name: "Lumemo",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Lumemo",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Lumemo/Sources",
                "Lumemo/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "LumemoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.LumemoTests",
            infoPlist: .default,
            buildableFolders: [
                "Lumemo/Tests"
            ],
            dependencies: [.target(name: "Lumemo")]
        ),
    ]
)
```

This will get you started with the Tuist infruscture. Like I said Tuist uses Swift for creating Xcode projects so editing the project is fairly simple. You edit the Project.swift directly or if you prefer to use Xcode you can call:

```
mise exec tuist -- tuist edit
```

This will create a temporary workspace for you edit the Swift files and make sure they "compile" in the Xcode. Once you are done you can simply close the temporary workspace and your edits will be in your repo. 

To create the Xcode project and workspace, just call:

```
mise exec tuist -- tuist generate
```

This will create the Xcode project and workspace where you can work on your app.

**Remember don't edit the project and workspace setting in Xcode directly. Edit the Project.swift file and other tuist related Swift files to save your changes to the repo.**

Now that we've setup our first project using tuist, let's dive into how the Xcode project works.

### Projects and their Targets

An Xcode target is the core of our Xcode project. It creates the the testable and deliverable app. Here's what a typical `Project.swift` looks like at this early stage:

```swift
import ProjectDescription

let project = Project(
  name: "Lumemo",
  targets: [
    .target(
      name: "Lumemo",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.brightdigit.Lumemo",
      sources: ["Sources/**"]
    )
  ]
)
```

Let’s take a look at how these map out:

<a target="_blank" href="/media/tutorials/tuist-xcode-project-setup/Swift-Automation-Tuist.webp">
<figure>
<img src="/media/tutorials/tuist-xcode-project-setup/Swift-Automation-Tuist.webp" alt="Diagram showing how the Tuist Project.swift files lines up with Xcode" class="full-size" />
<figcaption>Diagram showing how the Tuist Project.swift files lines up with Xcode.</figcaption>
</figure>
</a>

At the top, we have the name of the project "Lumemo". Inside we have out sets of targets. Typically Tuists sets up a test target but we removing that for simplicity sake for now. 

### Targets

A target could be anything from a app extension to a framework to a unit tests. Esentially anything which could in that target spot. These different types (app extension, framework, etc...) are defined as _product types_. In tuist, we use an enum called `Product`. In our case this is an `.app`.

We have a few identifiers here including the target name and the bundleId. The bundle identifier of course has the follow the reverse dns name and is unique to the app store. Target name is the name shown in the target list. Unless you specifically supply the product name, this will be used as the product name (i.e. the name of the ipa, app, pkg, etc...).

In this case we are setting our destination to `.iPhone`. This can be a variey of destination which are not only the platform (iOS) or device (iPad) but in cases where you want to target macOS or visionOS but build it from an iPad app or in case you wanted to build a Catalyst app for macOS.

Last but not least are your source files which can get an array glob strings. These are add the your project as source files and complied as so.

No that we have the basics, there are a few things we need to add so it's ready for app store deployment:

* Notice the os version is set to the very latest based on the default of your Xcode version. We should set this so it's stable across Xcode versions.
* We are missing an app icon.
* We can't build it because we don't have a deployment team defined.
* Small App Store required info is missing such as exempt encryption use and our privacy manifest
* Lastly we don't have a stable way to define the app version.

Lest's go through each of these.

### Deployment Targets

As stated earlier, destination defines not just the platform or device but what technology is used to deploy to a particular. This usually means the device class. However in cases where you are catalyst for macOS or allowing an iPad app's destination on a Mac or Vision Pro these specifics are required. 

To define the actual platform versions, you'd use the `deployTargets`. If this isn't set, Xcode will use whatever the latest version available for that version of Xcode. 

Under the hood, `DeploymentTargets` is just a set of properties for each Apple platform. In the `Project` intializer you can set the individual platform using one the static methods below:

```swift
    /// Convenience method for `iOS` only minimum version
    public static func iOS(_ version: String) -> DeploymentTargets

    /// Convenience method for `macOS` only minimum version
    public static func macOS(_ version: String) -> DeploymentTargets

    /// Convenience method for `watchOS` only minimum version
    public static func watchOS(_ version: String) -> DeploymentTargets

    /// Convenience method for `tvOS` only minimum version
    public static func tvOS(_ version: String) -> DeploymentTargets

    /// Convenience method for `visionOS` only minimum version
    public static func visionOS(_ version: String) -> DeploymentTargets
```

In our case we'll be targeting the minimum deployment version for iOS 26.0:

```swift
  deploymentTargets: .iOS("26.0"),
```

Just as with `destinations` we can set variety of destinations, we have can create a multiplatform app as well:

```swift
    /// Multiplatform deployment target
    public static func multiplatform(iOS: String? = nil, macOS: String? = nil, watchOS: String? = nil, tvOS: String? = nil, visionOS: String? = nil) -> ProjectDescription.DeploymentTargets
```


### App Icon

The app store requires App Icons before deployment. In our case since we are targeting a minimum of 26.0 we can use Icon Composer to create our app icon. To add it to app package, we just reference the file as a resource:

```swift
      resources: [
        "Resources/AppIcon.icon",
        ...
```

Xcode should automatically pick that up and use it. 

Asset catalogs, text files, etc... any other resource would go here and a glob pattern can be used here as well.

### Privacy Manifest

The Privacy Manifest is required too and can go under the resources property as well. If you need help building one there are some great resources here:


### Extending Other Default

Besides the privacy manifest, there's the `ITSAppUsesNonExemptEncryption` setting. If you ever tried to submit an app's first version to app review, you've seen this question asked.

<figure>
<img src="/media/tutorials/tuist-xcode-project-setup/AppStore-ITSAppUsesNonExemptEncryption.png" class="full-size" />
</figure>

Luckily we can skip this step by simply supplying this property in our Info.plist file. 

One thing great about Tuist, is that a lot of boiler plate and default values are already supplied to us for things like the Info.plist and the build settings. In our case we'll be using the `.extendingDefault(with:)` method to set `ITSAppUsesNonExemptEncryption` to `false`.

Let's do something like this for setting the development team. If you try to compile the app it will instantly complain that now development team is set. We can do this using the build settings and set it as a base property for all configurations:

```swift
      settings: .settings(
        base: [
          "DEVELOPMENT_TEAM": "MLT7M394S7",
        ]
      )
```

Both of these functions for Info.plist and settings, provide a plethoria of property values that most users don't need to touch. This allows us to simply provide only the few overrides we need.

One last piece I want to add is the ability to simplify version management.

### Version Management with xcconfig

An app and its Xcode project contain 2 pieces of version information:

* _Marketing Version_ (1.0.0) - this follows the typical semver string pattern and is what the user will see when they see the version number in the app store.
* _Build Number_ (39) - this is a unique integer that identifies each build uploading to the App Store which could be for submitting to app review or it could be submited to TestFlight or not even submitted at all.

These settings are stored in the Info.plist. The _Marketing Version_ is stored as a string as the property `CFBundleShortVersionString`. The _Build Number_ is stored as `CFBundleVersion`. Of course we just hard code these in our Project.swift file for tuist to consume:

```swift
      infoPlist: .extendingDefault(
        with: [
          "CFBundleShortVersionString": "1.0.0",
          "CFBundleVersion": "1",
          "ITSAppUsesNonExemptEncryption": false,
        ]
      ),
```      

However if you want to automate incrementing or updating the build number each time, I would prefer a more reliable way to then depnding on a regular expression to cleaning update these values. This is where an `xcconfig` file. xcconfig files are well-documented and simple to understand. They are similar to .env files but with additional abilities. Let's create a new file `Config/Version.xcconfig` and set the version info there:

```
MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 2
```

As you can tell it's just a name-value pair and we using our our nomenclarture for these values name. 

To let Tuist know about these we can import these into our build settings and configuration:

```swift
      settings: .settings(
        base: [
          "DEVELOPMENT_TEAM": "MLT7M394S7",
        ],
        configurations: [
          .debug(xcconfig: .relativeToRoot("Config/Version.xcconfig")),
          .release(xcconfig: .relativeToRoot("Config/Version.xcconfig")),
        ]
      )
```   

Notice we are making sure we import into both the `debug` and `release` configuration. Also since xconfig is the native method for configurations in Xcode tuist will refer to the xcconfg file in the generated Xcode project.

Lastly we need to reference these properties in our Info.plist. To refer to a specific property we use the variable notation of :

```
$(ALL_UPPER_CASE_SNAKE_CASE_PROPERTY_FROM_CONFIGURATION_SETTINGS)
```

So in our case, our `infoPlist` would look like:

```swift
      infoPlist: .extendingDefault(
        with: [
          "CFBundleShortVersionString": "$(MARKETING_VERSION)",
          "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
          "ITSAppUsesNonExemptEncryption": false,
        ]
      ),
```   

This will make it much easier to increment the build number or change the marketing version.

### Ignoring Our Project

This is what we should have for our end result:

```swift
import ProjectDescription

let project = Project(
  name: "Lumemo",
  targets: [
    .target(
      name: "Lumemo",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.brightdigit.Lumemo",
      deploymentTargets: .iOS("26.0"),
      infoPlist: .extendingDefault(
        with: [
          "CFBundleShortVersionString": "$(MARKETING_VERSION)",
          "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
          "ITSAppUsesNonExemptEncryption": false,
        ]
      ),
      sources: ["Sources/**"],
      resources: [
        "Resources/AppIcon.icon",
        "Resources/PrivacyInfo.xcprivacy",
      ],
      settings: .settings(
        base: [
          "DEVELOPMENT_TEAM": "MLT7M394S7",
        ],
        configurations: [
          .debug(xcconfig: .relativeToRoot("Config/Version.xcconfig")),
          .release(xcconfig: .relativeToRoot("Config/Version.xcconfig")),
        ]
      )
    )
  ]
)
```

This will give us a fully working Xcode project but before we commit this to our repository, we need to make sure we aren't commiting our project and workspace.

If you don't already have a .gitignore file, [toptal has a great resource for creating one](https://www.toptal.com/developers/gitignore). I even have a url I download from everytime:

```
https://www.toptal.com/developers/gitignore/api/xcode,swift,swiftpackagemanager,swiftpm,macos
```

This should give me everything I need for my Xcode project except that I'll need to ignore the workspace and project file. Search for the line:

```
# *.xcodeproj
```

If you can't find it, you can just add the line instead of replacing the commented out one with this:

```
*.xcodeproj
```

We'll want to do the same thing for Xcode workspaces, so make sure we have the line:

```
*.xcworkspace
```

Lastly dervied files or caches from Tuist should be ignored as well:

```
.tuist/
Derived/
```

Now would be a good time to commit and push this to your repo. Every time someone pull this repo, they should be able to use `mise` to execute `tuist` and generate the Xcode workspace and project.

### One More Thing

For a typical app, you may want to add a few other things:

* `entitlements` - these are permissions your app requires such as HealthKit, App Groups, etc... - this is set via a [Dictionary](https://developer.apple.com/documentation/bundleresources/entitlements)
* `Info.plist` - there are variety of settings you made need for your application
  * Apple Watch Componanion Settings - `WKApplication`, `WKCompanionAppBundleIdentifier`, `WKRunsIndependentlyOfCompanionApp`
  * File and URL Types - `CFBundleDocumentTypes`, `CFBundleURLTypes`, `UTExportedTypeDeclarations`, `UTImportedTypeDeclarations`
  * Usage Descriptions - text for various accesses request like geolocation, healthkit, etc...

<!-- Writing prompt — Entitlements / inline vs. .entitlements file:
You might expect to find a .entitlements file in the repo. Why isn't there one?
What does putting entitlements inline in Project.swift actually buy you — what problem does it solve? -->

### Where does all the source code go?

Right now you should have a fully buildable app. However as far as source code, this can be fairly limiting in its structure and compatability. We'll be talking about how we can breakdown our application's source code into Swift Packages for easier testing, flexible OS compatablity, and easier modularization.


<!-- Writing prompt — Sources / why it stays minimal:
What is the single file that must live in the Tuist target's Sources/ folder, and what does it do?
Why does everything else (views, models, business logic) live in a Swift Package instead?
What would happen if you put a view file directly in Sources/ rather than the package? -->
