# Release Notes

## 1.0.0-alpha.1

### Library
* Split ContributeMailchimp out of the brightdigit.com monorepo into a standalone package that turns sent Mailchimp campaigns into Markdown files with YAML front matter by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1
* Un-deprecate the module — it is again an actively supported import path rather than a deprecated one by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1
* Provide the Contribute trio for a newsletter issue — `Newsletter.Source`, `Newsletter.FrontMatterTranslator`, and `Newsletter.MarkdownExtractor` — plus the `Newsletter` `ContentType`, its `FrontMatter`, and a `Campaign` model by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1
* Build against the Swift 6.4 toolchain with complete strict concurrency, targeting macOS 15 / iOS 16 / tvOS 16 / watchOS 9 by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1

### Tests
* Add a standalone test suite covering the source, front matter, Markdown extraction, content, and write paths (`NewsletterSourceTests`, `NewsletterFrontMatterTests`, `NewsletterMarkdownExtractorTests`, `NewsletterContentTests`, `NewsletterWriteTests`) by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1

### Documentation
* Add a README explaining the Contribute seam and the Mailchimp-specific half it fills in, plus a `ContributeMailchimp.docc` catalog with logo resources by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1

### Dependencies
* Depend on Contribute for the generic write loop and on Spinetail to fetch campaigns and their archive HTML by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1

### Tooling & CI
* Set up mise-based linting and formatting with `.mise.toml`, `.swift-format`, `.swiftlint.yml`, `.periphery.yml`, `Scripts/lint.sh`, and `Scripts/header.sh` by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1
* Add the shared multi-platform CI template (macOS/Linux/Windows/Android) along with `check-unsafe-flags`, `swift-source-compat`, `cleanup-caches`, and Claude review workflows by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1
* Add a devcontainer, Dependabot config, `.swift-version` pin, `codecov.yml`, `.spi.yml`, `LICENSE`, and `AGENTS.md` agent instructions by @leogdion in https://github.com/brightdigit/ContributeMailchimp/pull/1
