---
title: Bushel of an App - Building the Crust
date: 2023-12-15 00:00
description: Unfortunately creating my own VM app seemed like a huge undertaking, how would I even get started?
featuredImage: /media/articles/bushel-launch/Machine-AppStore.webp
---

With all of Apple’s announcements, [there’s usually a few things I look for to entice to buy a new device or use a new API.](/articles/wwdc-swift-developer-guide/) **For WWDC2023, SwiftData was released.** I knew cobbling a setup using UserDefaults and Combine for complex records was not maintainable. Despite the fact that SwiftData may not be perfect as most APIs are not on release, I could bet the future of the app that this API as opposed to Core Data would be maintained by Apple for the future. 

<figure>
  <img src="/media/articles/bushel-launch/Combine.Mess.webp" class="contained">
  <figcaption>Combine & UserDefaults Database... I'm glad I'm not using this anymore</figcaption>
</figure>

I also learned my lesson trying to support Monterey. As a solo developer, **it was not worth losing some many APIs for a possibly wider audience.** I can begin to write an app for macOS Sonoma 14 in the summer and have plenty of time to be ready for the new OS.

---

* [Part 1 - From Seed of an Idea](/articles/bushel-launch-part-1)
* _Part 2 - Building the Crust_
* [Part 3 - Design, Architecture, and Automation](/articles/bushel-launch-part-3)
* [Part 4 - Making Cider from Apples](/articles/bushel-launch-part-4)

---

* **[SwiftData](#swiftdata)**
* **[SwiftUI](#swiftui)**
* **[Sandboxing](#sandboxing)**
* **[Virtualization](#virtualization)**
   * [New Snapshot API](#new-snapshot-api)
* **[Observation](#observation)**

---

<a id="swiftdata"></a>
## SwiftData

SwiftData is a pretty decent API for maintaining a database of relational sets of data. **Is it perfect? No. However it is what I’d expect from a first year API from Apple.**  

Honestly the biggest hurdle was the ever changing APIs as I went from one beta to the next - that’s something I should expect.

[As I’ve stated with any new API](/articles/new-api-swift-app/), it’s wrapping my head around the way they (Apple) think a relational local database should be done. To some it’s what they expect from MySQL, Postgres, or SQLite. Having committed years of doing development in Vapor, my Swift _database_ work was done with [Fluent API](https://docs.vapor.codes/fluent/overview/).

[Fluent is Vapor’s default framework for interfacing with a server database.](https://docs.vapor.codes/fluent/overview/) The way they handled concepts such as relationships, Fluent and SwiftData were far apart. Additionally was the introduction of Swift Macros which creates even more complexity. 

For instance the night before WWDC, I created a LivePreview structure. Then the following day after, I added the new LivePreview macro and my code would not compile. I was puzzled until I realized how Macros worked.

I have heard a lot of valid criticisms regarding SwiftData - all if not most valid. For me however I thought about long term support and where I wanted to invest my time. Pulling in a third party library was an option but one I wanted to avoid. 

My biggest regret was not employing the use of ModelActors in Bushel. 

<figure>
  <img src="/media/articles/bushel-launch/ModelActor.webp" class="full-size">
  <figcaption>Still not sure how these work exactly</figcaption>
</figure>

**Through my scouring of videos and documentation I found little on the topic** and as SwiftData progressed through Xcode betas and integrated with SwiftUI I found the issue of threading and actors becoming more and more important. **My hope is that I employ these throughout a future version of the App.**

<a id="swiftui"></a>
## SwiftUI

With the decision to only support macOS Sonoma and up came the freedom to use the latest and greatest in SwiftUI APIs. For macOS this especially meant the use window management APIs as opposed to the messy way of handling windows via AppKit and URL hacks.

<figure>
  <img src="/media/articles/bushel-launch/Monterey.Windows.webp" class="full-size">
  <figcaption>So glad to get rid of this</figcaption>
</figure>

**The biggest hurdle was tackling the issue with the Document-Based APIs.** In the end, it became evident to ditch those for my own implementation. There were many reasons for this but the gains made through Apple’s API did not make sense compared to freedom I would get with my own implementation. The _free_   APIs did not add many benefits for a system using such large and complex file types.

Looking back, I very confident this was the right decision. This meant a lot of AppKit hacks could be removed for managing window. However there were a few instances where I needed AppKit in order to customize or optimize the UI such as:

- custom `NSOpenPanel` and `NSSavePanel`
- improve Virtual Machine session window
- handling window state via `NSWindowDelegate`

```swift
//
// View+NSWindowDelegate.swift
// Copyright (c) 2023 BrightDigit.
//

#if canImport(AppKit) && canImport(SwiftUI)
  import AppKit
  import SwiftUI

  private struct NSWindowDelegateAdaptorModifier: ViewModifier {
    @Binding var binding: NSWindowDelegate?
    
    // swiftlint:disable:next weak_delegate
    let delegate: NSWindowDelegate

    init(
      binding: Binding<NSWindowDelegate?>,
      delegate: @autoclosure () -> NSWindowDelegate
    ) {
      self._binding = binding
      self.delegate = binding.wrappedValue ?? delegate()

      self.binding = self.delegate
    }

    func body(content: Content) -> some View {
      content.nsWindowAdaptor { window in
        assert(!self.delegate.isEqual(window?.delegate))
        assert(window != nil)
        window?.delegate = delegate
      }
    }
  }

  public extension View {
    func nsWindowDelegateAdaptor(
      _ binding: Binding<NSWindowDelegate?>,
      _ delegate: @autoclosure () -> NSWindowDelegate
    ) -> some View {
      self.modifier(
        NSWindowDelegateAdaptorModifier(
          binding: binding,
          delegate: delegate()
        )
      )
    }
  }
#endif

```

I am sure there are blind spots to the API however I am sure they are rare and easily fixable.

<a id="sandboxing"></a>
## Sandboxing

I wanted to least amount of friction in _deploying_ the app so the Mac App Store became the obvious choice for the immediate future. This meant I needed to work with Sandboxing in order to publish the app.

This means most of all working with file URL bookmarks. Since I was already employing SwiftData, that becomes the obvious place.

<figure>
  <img src="/media/articles/bushel-launch/Database.Diagram.svg" class="contained">
  <figcaption>Database Diagram</figcaption>
</figure>

**[Bushel](https://getbushel.app)** uses the rigorous system of using SwiftData to consistently gain and keep access to various files. Since we are using packaged directories, once we create a bookmark for the packaged directory, Virtualization will have proper access to all the components.

As previously stated, sandboxing is the reason a Library document type was created since it ensures **[Bushel](https://getbushel.app)** will have consistent access to ipsw files inside a library.

<a id="virtualization"></a>
## Virtualization

The Virtualization framework is surprisingly not the most difficult part of the application. However there are a few challenges related to Virtualization, tracking state with SwiftUI, Restore Image support, and Snapshots.

<a id="new-snapshot-api"></a>
### New Snapshot API

Before the release of macOS Sonoma I did create snapshot feature using [`NSFileVersion`](https://developer.apple.com/documentation/foundation/nsfileversion), however with WWDC we were introduced to [a new API for _saving the machine state._](https://developer.apple.com/documentation/virtualization/vzvirtualmachine/4168516-savemachinestateto) With no longer supporting Monterey I figured this would be the ideal way to save the machine state. Unfortunately there is one major drawback, saving machine state is only supported for Virtual Machines with Sonoma installed. 

For an app which is supposed to allow users to test their app on older operating systems, this is useless. This meant that unlike my work in UserDefaults & Combine or the old SwiftUI Window Management code, using NSFileVersion originally was a benefit. [`NSFileVersion`](https://developer.apple.com/documentation/foundation/nsfileversion) has very little documentation and is mostly used along with iCloud. However it does its job. Unfortunately due to the nature of APFS and NSFileVersion, the biggest issue is the that I have no way in knowing how much each snapshot takes up in disk space. I was really looking forward to add SwiftUI Pie Chart showing the file space allocation but that’ll have to wait for now.

<figure>
  <img src="/media/articles/bushel-launch/DFU.Feedback.webp" class="contained">
  <figcaption>My DFU Feedback Filed</figcaption>
</figure>

---


![Library Window from Bushel](/media/articles/bushel-launch/Library-AppStore.webp)

Another issue is that **certain restore images are simply not supported.** Either the version is too old which is the case for anything before macOS 12.0.1 or **Apple know longer allows using the image.** My guess is that this is purposeful on Apple’s part due to security updates. While I can’t work around this, I can at least communicate that clearly to the user for now.

Much of the Virtualization framework is built on top of Objective-C based code, which means it isn’t using a method friendly to SwiftUI. Therefore I needed to listen to changes to the virtual machine either via the Delegate pattern or Key Value Changed. 

```swift
//
// KVObservation.swift
// Copyright (c) 2023 BrightDigit.
//

#if canImport(ObjectiveC)
  import Foundation

  public protocol KVObservation: AnyObject {}

  extension NSObject {
    public static func getAllPropertyKeys() -> [String] {
      Self.getAllPropertyKeys(of: Self.self)
    }

    private static func getAllPropertyKeys<ClassType: AnyObject>(of _: ClassType.Type) -> [String] {
      let classType: AnyClass = ClassType.self
      return self.getAllPropertyKeys(of: classType)
    }

    private static func getAllPropertyKeys(of classType: AnyClass) -> [String] {
      var count: UInt32 = 0
      let properties = class_copyPropertyList(classType, &count)
      var propertyKeys: [String] = []

      for index in 0 ..< Int(count) {
        if
          let property = properties?[index],
          let propertyName = String(utf8String: property_getName(property)) {
          propertyKeys.append(propertyName)
        }
      }

      free(properties)
      return propertyKeys
    }

    public func addObserver(
      _ observer: NSObject,
      options: NSKeyValueObservingOptions,
      _ isIncluded: @escaping (String) -> Bool = { _ in true }
    ) -> KVObservation {
      let propertyKeys = self.getAllPropertyKeys().filter(isIncluded)
      return self.addObserver(observer, forKeyPaths: propertyKeys, options: options)
    }

    private func addObserver(
      _ observer: NSObject,
      forKeyPaths keyPaths: [String],
      options: NSKeyValueObservingOptions
    ) -> KVObservation {
      for keyPath in keyPaths {
        self.addObserver(observer, forKeyPath: keyPath, options: options, context: nil)
      }

      return KVNSObservation(observed: self, observer: observer, keyPaths: keyPaths)
    }

    private func getAllPropertyKeys() -> [String] {
      let classType: AnyClass = type(of: self)

      return Self.getAllPropertyKeys(of: classType)
    }
  }
#endif
```
On top of this was built a class which would monitor changes and update properties accordingly for SwiftUI consumption. The choice for me was what kind of _observing_ would I do.

<a id="Observation"></a>
### Observation
As a big fan of Combine’s react pattern, I had used Combine through much of the application to react to changes in a model. However I could see some drawbacks:

- complex functional programming produced confusing code
- testing can become overwrought and difficult
- maintenance becomes challenging as designed behavior changes.

**With WWDC2023, I had the opportunity to pivot to the new Observation framework.** I was willing to give it shot since I knew Apple was investing in it and I was already redoing much of the underlying SwiftUI anyways. There were major benefits to the switch:

- Natively supported with SwiftData
- Simpler tracking of changes and updates
- Easier separation of logic and properties

Throughout the app, Observation is used. For every View, there’s an Observable Object tired to it which contains nearly all the properties used by the object. Rather than using `withObservationTracking` which I found misleading I used `didSet` which felt incorrect but the lack of documentation and the simplicity of its functionality worked perfectly with the application.

With using the new WindowGroup API, I used a patten throughout the app which the View would listen to changes to the @Binding object passed to it and let the Observation object know.

```swift
//
// DocumentView.swift
// Copyright (c) 2023 BrightDigit.
//

#if canImport(SwiftUI)
  import BushelCore
  import BushelLocalization
  import BushelLogging
  import BushelMachine
  import BushelMachineEnvironment
  import SwiftUI

  struct DocumentView: View, Loggable {
    @State var object = DocumentObject()
    @Binding var machineFile: MachineFile?

    var body: some View {
      TabView {
        DetailsView(machineObject: object.machineObject)
          .tabItem {
            Label(LocalizedStringID.machineDetailsSystemTab, systemImage: "list.bullet.rectangle.fill")
          }
        #if os(macOS)
          SnapshotsView(url: object.url, machineObject: object.machineObject).tabItem {
            Label("Snapshots", systemImage: "camera")
          }
        #endif
      }
      .onAppear {
        self.beginLoadingURL(machineFile?.url)
      }
      .onChange(of: self.machineFile?.url) {
        self.beginLoadingURL($1)
      }
    }

    func beginLoadingURL(_ url: URL?) {
      self.object
        .beginLoadingURL(
          url,
          withContext: context,
          restoreImageDBfrom: machineRestoreImageDBFrom.callAsFunction(_:),
          snapshotFactory: snapshotProvider,
          using: systemManager,
          metadataLabelProvider.callAsFunction(_:_:)
        )
    }
  }
#endif
```

There were also some [common developer tools and optimization I made in my build and deployment process as well.](/articles/bushel-launch-part-3)