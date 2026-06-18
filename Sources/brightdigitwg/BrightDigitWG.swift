import BrightDigitArgs

@main
internal enum BrightDigitWG {
  internal static func main() async {
    // BrightDigitWGRunner dispatches every command via ConfigKeyKit +
    // swift-configuration (issue #44; the ArgumentParser tree was removed).
    await BrightDigitWGRunner.run()
  }
}
