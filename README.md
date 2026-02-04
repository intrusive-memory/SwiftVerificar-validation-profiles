# SwiftVerificar-validation-profiles

Swift port of [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles).

## Overview

SwiftVerificar-validation-profiles provides XML validation rule definitions for PDF/A and PDF/UA standards, including:

- PDF/UA-1 and PDF/UA-2 accessibility profiles
- PDF/A-1, PDF/A-2, PDF/A-3, PDF/A-4 archival profiles
- Rule loader and parser

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

let loader = ProfileLoader()
let profile = try await loader.loadProfile(.pdfUA2)
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

## Source Reference

- **Original**: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
- **Format**: XML validation rules
- **License**: GPLv3+ / MPLv2+

## Development

See the parent [SwiftVerificar/AGENTS.md](../AGENTS.md) for development guidelines.

### Building

```bash
xcodebuild build -scheme SwiftVerificarValidationProfiles -destination 'platform=macOS'
```

### Testing

```bash
xcodebuild test -scheme SwiftVerificarValidationProfiles -destination 'platform=macOS'
```
