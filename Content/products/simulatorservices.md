---
title: SimulatorServices
platforms: macOS
technologies: Swift, Vapor, simctl
description: Control the simulator... in Swift
githubRepoName: SimulatorServices
date: 2023-02-02 10:30
featuredImage: /media/products/simulatorservices/logo.svg
---
SimulatorServices provides an easy to use API for managing, querying, and accessing simulators on your Mac.

SimulatorServices allows you to execute subcommands to simctl directly in Swift while offering an easy to use API for parsing and passing arguments.

SimulatorServices uses the SimCtl object to pass subcommands. Each subcommand objects takes custom arguments or property and can parse the standard output into an easy to use Swift object. There are currently two supported subcommands: GetAppContainers and List.