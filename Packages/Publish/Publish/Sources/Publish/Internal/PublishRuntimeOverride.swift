/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Internal task-local overrides used to make otherwise process-global inputs
/// (such as the command line arguments) injectable during testing, without
/// mutating shared global state — which is unsafe under strict concurrency.
internal enum PublishRuntimeOverride {
    /// When set, this value is used instead of `CommandLine.arguments` when the
    /// pipeline decides whether to run in generation or deployment mode.
    @TaskLocal static var commandLineArguments: [String]?
}
