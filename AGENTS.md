# SwiftVerificarValidationProfiles — Agent Instructions

## Overview

**Module name**: `SwiftVerificarValidationProfiles`

XML validation profiles for PDF/A, PDF/UA, and WCAG standards. This library provides rule definitions, profile loading, expression parsing, and expression evaluation that drive the SwiftVerificar validation engine.

- 40 public types
- 686 tests, 91.75%+ coverage
- No external dependencies
- Swift 6.0, all types `Sendable`, Swift Testing framework

## Key Public Types

### Enumerations

| Type | Cases | Description |
|------|-------|-------------|
| `PDFFlavour` | 17 | Identifies which standard to validate against: `pdfA1a`, `pdfA1b`, `pdfA2a`, `pdfA2b`, `pdfA2u`, `pdfA3a`, `pdfA3b`, `pdfA3u`, `pdfA4`, `pdfA4e`, `pdfA4f`, `pdfUA1`, `pdfUA2`, `wcag22`, `wtpdf1Accessibility`, `wtpdf1Reuse` |
| `Specification` | 11 | ISO standard references (e.g., ISO 19005-1, ISO 14289-2) |
| `PDFObjectType` | 188 | All PDF object types across COS, PD, SE, SA layers |
| `RuleTag` | 18 | Severity, checkability, and category tags for rules |
| `RuleExpression` | — | AST for parsed rule test expressions |
| `PropertyValue` | — | Runtime values: `null`, `bool`, `int`, `double`, `string`, `array` |

### Structs

| Type | Description |
|------|-------------|
| `ValidationProfile` | Complete profile with rules, variables, and metadata |
| `ValidationRule` | Single validation rule with test expression and error details |
| `RuleID` | Unique rule identifier composed of `spec` + `clause` + `testNumber` |
| `ErrorDetails` | Error message template with argument substitution |
| `ProfileVariable` | Configurable variable within a profile |

### Actors and Services

| Type | Description |
|------|-------------|
| `ProfileLoader` | Thread-safe singleton actor for loading profiles from bundled XML |
| `ProfileXMLParser` | Parses XML profile files into `ValidationProfile` structs |
| `RuleExpressionEvaluator` | Evaluates rule test expressions against PDF object contexts |
| `ProfileValidator` | Validates profile integrity |
| `ProfileDirectory` | High-level actor for profile queries |
| `RuleTestRunner` | Executes rules against PDF objects |
| `ExpressionParser` | Parses rule test expression strings into `RuleExpression` AST |

### Type Aliases

| Type | Description |
|------|-------------|
| `ExpressionPropertyValue` | Typealias to avoid module/struct name collision with `PropertyValue` |

## Common Usage Patterns

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

## Bundled Resources

733 XML profile files organized in two directories:

```
Resources/
├── PDF_A/           # PDF/A rules (ISO 19005)
│   ├── 1a/
│   ├── 1b/
│   ├── 2a/
│   ├── 2b/
│   ├── 2u/
│   ├── 3a/
│   ├── 3b/
│   ├── 3u/
│   ├── 4/
│   ├── 4e/
│   └── 4f/
└── PDF_UA/          # PDF/UA rules (ISO 14289)
    ├── 1/
    ├── 2/
    └── WTPDF/
```

## Build and Test

**CRITICAL**: NEVER use `swift build` or `swift test`. Always use `xcodebuild`.

```bash
# Build
cd /Users/stovak/Projects/SwiftVerificar/SwiftVerificar-validation-profiles
xcodebuild build -scheme SwiftVerificarValidationProfiles -destination 'platform=macOS'

# Test
cd /Users/stovak/Projects/SwiftVerificar/SwiftVerificar-validation-profiles
xcodebuild test -scheme SwiftVerificarValidationProfiles -destination 'platform=macOS'
```

## Architecture Notes

- All types conform to `Sendable` for Swift 6 strict concurrency
- `ProfileLoader` is an actor with a shared singleton — thread-safe caching of loaded profiles
- `ProfileDirectory` is an actor providing high-level queries across all profiles
- Expression evaluation uses an AST (`RuleExpression` enum) parsed by `ExpressionParser` and evaluated by `RuleExpressionEvaluator`
- `PropertyValue` represents runtime values during expression evaluation
- XML profiles are bundled as Swift Package Manager resources and loaded on demand

## Source Reference

- **Original**: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
- **Format**: XML validation rules (validationProfile.xsd schema)
- **License**: GPLv3+ / MPLv2+
