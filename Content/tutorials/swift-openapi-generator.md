---
title: Getting Started with Swift OpenAPI Generator
date: 2024-01-30 02:37
description: Here's how to get started with the Swift OpenAPI Generator
featuredImage: /media/tutorials/swift-openapi-generator/working-transferring-robot-in-factory-hall-logist-2023-11-27-05-22-50-utc.webp
---

With the launch of Bushel, I created the concept of a _Hub_. A _Hub_ is an online repository or source that provides you with a collection of macOS restore images (.ipsw files). Hubs serve as convenient sources for obtaining various versions of macOS to import into your Library for setting up virtual machines.

At launch, there was only the default Apple _Hub_ which returns the latest production release of macOS. Now I been wanting to support the use of IPSW [IPSW Downloads](https://ipsw.me) which provides a plethora of images. Thankfully IPSW Downloads provides an API and documentation.

In this article I'm going to cover:

- getting **your YAML ready** for the generator
- setting up your **new Swift package**
- preparing your package **for public consumption**

## Getting Ready

In some cases the service, might not provide the exact spec needed. In the case of IPSW Downloads, it does not provide an OpenAPI document but rather an [API Blueprint](https://apiblueprint.org) document. API Blueprint is a markdown alternative to OpenAPI which means I need a way to convert the API Blueprint markdown to OpenAPI yaml. For this I found [apib2swagger](https://github.com/kminami/apib2swagger), which takes a API Blueprint file and outputs a OpenAPI YAML file. Many developers do provide great OpenAPI documentation, however there will be cases where you'll need to convert their specifications with a tool of some sort or perhaps your favorite AI tool.

In any case it’s worth learning the details of OpenAPI docs at some point since all conversions are approximate and imperfect. For this I found [Swagger docs pretty accessible](https://swagger.io/docs/specification/data-models/data-types/) for defining data types [Stoplight](https://stoplight.io) for creating new APIs.

Now I can get started building integrating IPSW Downloads with Bushel. 

## From YAML to Swift

Let’s start by just creating a Swift Package for only the IPSW Downloads API. So let’s start by creating a Swift Package. Inside the Package.swift we need to add dependencies:

```
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
	name: "IPSWDownloads",
	platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
	products: [
		.library(name: "IPSWDownloads", targets: ["IPSWDownloads"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0")
	],
	targets: [
		.target(
			name: "IPSWDownloads",
			dependencies: [
				.product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
				.product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
			],
			plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
		)
	]
)
```

In the target directory `/Sources/IPSWDownloads`, we need to add our `openapi.yaml` file to and a `openapi-generator-config.yaml` file:

```yaml
generate:
	- types
	- client
accessModifier: internal
```

There are [plenty of options available](https://swiftpackageindex.com/apple/swift-openapi-generator/1.2.0/documentation/swift-openapi-generator/configuring-the-generator) for the `openapi-generator-config.yaml` which configures the generator. Most importantly, we are:

- specifying the `accessModifier` to be `internal`
- asking it to `generate` the necessary code. For which there are 3 options available:
  - server - code stubs which are required for implementing a server in Swift (i.e. Vapor, Hummingbird, etc....)
	- client - used to communicate with an outside service which I'm implementing (i.e. used by iOS, watchOS, visionOS, etc...)
	- types - the required data models for communication on either the client or server
	

By adding these files, in Xcode or via the command line, the OpenAPI generator plugin creates two Swift files which are compiled in the background: `Types.swift` and `Client.swift`. 

## Going Public

From here I can make a few modifications before publishing my Swift Package:

* abstract the types used by the OpenAPI document
* include the generated Swift files in my Swift Package

### Curating vs Transparent

We could transparently provide the types generated to the public by modifying the `accessModifier` in `openapi-generator-config.yaml`  :

```yaml
generate:
	- types
	- client
accessModifier: public
```

However this isn’t really recommended practice. [The curated example provided](https://github.com/apple/swift-openapi-generator/tree/main/Examples/curated-client-library-example) suggests creating an intermediary abstraction for your public consumers and the actual OpenAPI types. This is the practice I followed with the IPSW Downloads API. 

Here's an example of a `Firmware` type which is it's own type but is _converted_ from the OpenAPI `Components.Schema.Firmware` type:

```swift
import Foundation

public struct Firmware {
	public let identifier: String
	public let version: OperatingSystemVersion
	public let buildid: String
	public let sha1sum: String
	public let md5sum: String
	public let filesize: Int
	public let url: URL
	public let releasedate: Date
	public let uploaddate: Date
	public let signed: Bool
}

extension Firmware {
	// Convert the generated `Components.Schemas.Firmware` into our public `Firmware`
	internal init(component: Components.Schemas.Firmware) throws {
		// parse the OpenAPI version string into an actual `OperatingSystemVersion`
		let version = try OperatingSystemVersion(string: component.version)
		
		// parse the OpenAPI url string into an actual `URL`
		let url = try URL(validatingURL: component.url)
		
		try self.init(
			identifier: component.identifier,
			version: version,
			buildid: component.buildid,
			sha1sum: component.sha1sum,
			md5sum: component.md5sum,
			filesize: component.filesize,
			url: url,
			releasedate: component.releasedate,
			uploaddate: component.uploaddate,
			signed: component.signed
		)
	}
}
```

You can see we are parsing the `OperatingSystemVersion` and the `URL` into the appropriate types. If there's some conversion missing in the OpenAPI conversion (i.e. `URL`) or the spec may change and you wish to allow a something transition for consumers of your API, **it's worth curating the OpenAPI in your public library.**

### Plugin vs CLI

Do we want to use the Swift Package plugin or generate manually and include the generated files in our repo? 

If you go with the Swift Package plugin and make your package available, developers who consume it **will be prompted in Xcode to allow the plugin to run**. In my case, this causes friction for outside devs importing your library. So rather than using the plugin I decided to generate the code myself and include it in the repo. To generate the code in IPSWDownloads I created a script which calls `generate` manually:

```
swift run swift-openapi-generator generate \ 
	--output-directory Sources/IPSWDownloads/Generated \
	--config openapi-generator-config.yaml \
	openapi.yaml
```

Here you specify the `output-directory` and the last argument is the path to the `openapi.yaml` file. The configuration in this case uses our previously created `openapi-generator-config.yaml`. However we do have the option to specify configuration manually using options such as `access-modifier` and `types`.

## Plugging into Bushel

Luckily once the library is completed, it's fairly simple plugging this into Bushel. You can [use the library yourself](https://github.com/brightdigit/IPSWDownloads) or [you can try this yourself by signing up the latest beta of Bushel](https://getbushel.app/).

If you plan to create your own API or adopt one for Swift using the OpenAPI generator, here are some tips:

- **not everyone has an OpenAPI doc** and may require some conversion, AI help, or just plain editing
- if you plan to publish this, **strongly consider curating your API** for more friendly access
- until the Swift package plugins are more widely accepted **consider pre-generating your OpenAPI code via the CLI**

Let me know if you've created any thing via the OpenAPI generator. What's been your biggest challenge? What did your learn? Follow me and let me know what you think of the Swift OpenAPI Generator.
