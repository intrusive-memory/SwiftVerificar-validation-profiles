# SwiftVerificar-validation-profiles

Swift port of [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles).

## Overview

SwiftVerificar-validation-profiles provides XML validation profile definitions for PDF/A and PDF/UA standards, providing rule definitions that drive the SwiftVerificar validation engine. Contains 733 bundled XML profile files covering PDF/A-1 through PDF/A-4 and PDF/UA-1 and PDF/UA-2. Part of the SwiftVerificar suite.

- 40 public types
- 686 tests, 91.75%+ coverage
- 7 sprints to complete

**Requirements**: Swift 6.0+, macOS 14.0+, iOS 17.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/intrusive-memory/SwiftVerificar-validation-profiles.git", from: "0.1.0")
]
```

## Usage

```swift
import SwiftVerificarValidationProfiles

// Load a profile
let profile = try await ProfileLoader.shared.loadProfile(for: .pdfUA2)

// Access profile rules
for rule in profile.rules {
    print(rule.ruleID, rule.description)
}

// Evaluate a rule expression
let evaluator = RuleExpressionEvaluator()
let result = try evaluator.evaluate(rule.testExpression, context: context)
```

## Supported Profiles

### PDF/UA (Accessibility)
- PDF/UA-1 (ISO 14289-1)
- PDF/UA-2 (ISO 14289-2:2024)

### PDF/A (Archival)
- PDF/A-1a, PDF/A-1b (ISO 19005-1)
- PDF/A-2a, PDF/A-2b, PDF/A-2u (ISO 19005-2)
- PDF/A-3a, PDF/A-3b, PDF/A-3u (ISO 19005-3)
- PDF/A-4, PDF/A-4e, PDF/A-4f (ISO 19005-4)

### WCAG / WTPDF
- WCAG 2.2
- WTPDF 1.0 Accessibility
- WTPDF 1.0 Reuse

## Porting Process

This library was ported from its Java source using a structured, AI-assisted methodology. The original veraPDF Java codebase was analyzed to extract type hierarchies, public APIs, and behavioral contracts. An execution plan decomposed the port into sequential sprints, each targeting a cohesive set of types with explicit entry/exit criteria (build must pass, all tests must pass, 90%+ coverage). AI coding agents (Claude) executed each sprint autonomously — translating Java patterns to idiomatic Swift (enums for sealed hierarchies, structs for value types, actors for thread-safe singletons, async/await for concurrency), writing Swift Testing framework tests, and verifying builds with xcodebuild. A supervisor process coordinated sprint sequencing, tracked cross-package dependencies, and performed reconciliation passes to ensure type agreement across the five-package ecosystem. The result is a clean-room Swift implementation that preserves the original's validation semantics while embracing Swift 6 strict concurrency, value semantics, and protocol-oriented design.

## Source Reference

- **Original**: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
- **Format**: XML validation rules
- **License**: GPLv3+ / MPLv2+

## Development

### Building

```bash
xcodebuild build -scheme SwiftVerificarValidationProfiles -destination 'platform=macOS'
```

### Testing

```bash
xcodebuild test -scheme SwiftVerificarValidationProfiles -destination 'platform=macOS'
```

**NEVER use `swift build` or `swift test`.**
