---
title: Connecting Observation with Binding in SwiftUI
date: 2024-01-09 00:00
description: How can you use a WindowGroup with Binding and the new Observation framework in SwiftUI
featuredImage: /media/tutorials/observation-binding-swiftui/arrows-2023-11-27-04-57-39-utc.webp
---

When I was building [Bushel](https://getbushel.app), I ran into an issue where the `@Binding` object passed to a view would change as the app loaded. 
This made it difficult to maintain a `@Binding` object and use the [new Observation framework.](https://developer.apple.com/documentation/observation?changes=__3_5) 
However I did find a pattern which allowed me to use a `@Binding` object while keeping the complex functionality 
needed for an @Observed object.

## Dynamic `@Binding`

Whenever [Bushel](https://getbushel.app) would open a new Window of a view it would pass an argument with a `@Binding` value. [This is part of the API for a `WindowGroup`](https://developer.apple.com/documentation/swiftui/windowgroup/init(for:content:)):

```
init<D, C>(
    for type: D.Type,
    @ViewBuilder content: @escaping (Binding<D?>) -> C
) where Content == PresentedWindowContent<D, C>, D : Decodable, D : Encodable, D : Hashable, C : View
```

Notice the the `D` data must implement `Codable` as well as `Hashable` which in most cases should be a simple comparable struct. In our view though we'd like to use the new `@Observable` macro which requires a class. 

Therefore we'll need to use the `@Binding` value to setup the `@Observable` object. That is until `@Binding` properties change. When would that be? 
In most case **when the app is re-opened:**

1. Open Window with nil `@Binding` object.
2. App loads pervious View State with actual Input data.
3. `@Binding` value changes with new data.

This means:

* I need to listen to those changes of the passed `@Binding` object
* I need to setup the View to notify the `@Observable` class object of the new changes.

## When Binding Changes

For instance, here's an example of a `WindowGroup` which takes in a `@Binding` struct of an `InputObject`. 

```
struct InputObject : Codable, Hashable {
  let text : String
}

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup(for: InputObject.self) { input in
      ContentView(input: input)
    }
  }
}
```

I can use the `@Binding InputObject` directly in my SwiftUI View. However, in order to use the [Observation framework](https://developer.apple.com/documentation/observation?changes=__3_5) I need a class object property in my SwiftUI View.

## Updating Observed Object
Here is the SwiftUI view we are using:

```
struct ContentView: View {
  @Binding var input : InputObject?
  @State var object = OutputObject()
  var body: some View {
    VStack {
      Image(systemName: object.systemName)
            .imageScale(.large)
            .foregroundStyle(.tint)
      Text(object.message)
    }
    .padding()
  }
}
```

For my `@Observable`  object called `OutputObject` it will contain all the information needed to render the view. In this case it contains the String message and the SF Symbol system name.

```
@Observable
class OutputObject {
  enum SymbolSystemName : String {
    case newItem = "doc.fill.badge.plus"
    case existingItem = "hand.thumbsup.fill"
  }
    
  var newInputText = ""
  
  var message : String
  
  var symbolSystemName : SymbolSystemName = .newItem
  
  var systemName : String {
    return self.symbolSystemName.rawValue
  }
}
```

The next step is to add a way to let the `@Observable`  object know of the `InputObject` passed top the view. While in the past, I’d use Combine in this case I will use the SwiftUI view as the mediator to let the `@Observable`  object know. 
Firstly let’s add the `InputObject` as a property and have it update our properties when it changes:

```
@Observable
class OutputObject {
	...
  var input : InputObject? {
    didSet {
      self.message = self.input?.text ?? Self.newItemMessage
      self.symbolSystemName = self.input == nil ? .newItem : .existingItem
    }
  }
}
```

Next we’ll use the modifier `onChange` to send any changes in `InputObject` to the `OutputObject`:

```
struct ContentView: View {
  @Binding var input : InputObject?
  @State var object = OutputObject()
    var body: some View {
        VStack {
          Image(systemName: object.systemName)
                .imageScale(.large)
                .foregroundStyle(.tint)
          Text(object.message)
        }
        .onChange(of: self.input, initial: true) { oldValue, newValue in
          self.object.input = newValue
        }
        .padding()
    }
}
```

Now the `@Observable` object will be updated accordingly when the `WindowGroup` updates the `InputObject` inside the `@Binding`. 

## Keeping things in Sync

It's important to keep the data in sync between what's passed from the `WindowGroup` and your `@Observable` object. This is especially important during the reloading of a previously open window after the application re-launches. In these cases, I use the `@Observable` object as the source of truth for my SwiftUI View. Here some key points to remember:

* The `@Observable` object and the `@Binding` value **must be separate since they have different requirements**: Class and Codable & Hashable Struct respectively. 
* However **I can use the `onChange`** to listen to changes in the `@Binding` value and let the `@Observable` object react accordingly. 

If you are doing any development using `WindowGroup` and want to take advantage of the new `Observable` framework using this pattern will be extremely helpful. 
