import BrightDigitArgs

@main
internal enum BrightDigitWG {
  internal static func main() async {
    // Migrated swift-configuration commands (issue #44) get first refusal; if
    // none match, fall back to the legacy ArgumentParser command tree.
    if await ConfigCommandDispatcher.tryRun() {
      return
    }
    await BrightDigitSiteCommand.main()
  }
}
