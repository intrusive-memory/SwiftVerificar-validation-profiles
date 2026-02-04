# SwiftVerificar-validation-profiles — Agent Instructions

Swift port of [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles).

See the parent [SwiftVerificar/AGENTS.md](../AGENTS.md) for ecosystem overview, implementation roadmap, and general guidelines.

## Purpose

Validation profile definitions providing:

- XML validation rules for PDF/A and PDF/UA
- Profile loader and parser
- Rule definitions for compliance checking

## Source Reference

- **Original**: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
- **Format**: XML (validationProfile.xsd schema)
- **License**: GPLv3+ / MPLv2+

## Profile Structure (Original)

```
veraPDF-validation-profiles/
├── PDF_A/           # PDF/A rules (ISO 19005)
│   ├── 1a/
│   ├── 1b/
│   ├── 2a/
│   ├── 2b/
│   ├── 3a/
│   ├── 3b/
│   └── 4/
└── PDF_UA/          # PDF/UA rules (ISO 14289)
    ├── 1/
    ├── 2/
    └── WTPDF/
```

## Key Types to Implement

```swift
// Profile Types
enum ProfileType
struct XMLProfile
struct XMLRule

// Loader
actor ProfileLoader

// Parser
struct ProfileXMLParser
```

## Implementation Strategy

1. **Import XML profiles** — Copy relevant XML files from veraPDF-validation-profiles
2. **Parse with XMLParser** — Use Foundation's XMLParser for profile loading
3. **Bundle as resources** — Include XML files as package resources
4. **Lazy loading** — Load profiles on demand to minimize memory usage

## Priority Profiles (for Lazarillo)

1. **PDF/UA-2** — Primary target for accessibility validation
2. **PDF/UA-1** — Secondary accessibility profile
3. **PDF/A-2a** — Archive with accessibility
4. **PDF/A-1b** — Basic archive compliance
