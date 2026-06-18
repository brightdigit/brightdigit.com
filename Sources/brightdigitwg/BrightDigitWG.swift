import BrightDigitArgs

@main
internal enum BrightDigitWG {
  internal static func main() async {
    // BrightDigitWGRunner dispatches migrated ConfigKeyKit commands (issue #44)
    // and falls back to the legacy ArgumentParser tree for everything else.
    await BrightDigitWGRunner.run()
  }
}
