# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-07

### Added
- Initial release of SwiftVerificarValidationProfiles
- PDFFlavour enum with 17 standard variants (PDF/A-1a through PDF/A-4f, PDF/UA-1, PDF/UA-2, WCAG 2.2)
- Specification enum with 11 ISO standard references
- PDFObjectType enum with 188 cases spanning COS, PD, SE, SA layers
- ValidationProfile, ValidationRule, RuleID, ErrorDetails, ProfileVariable model types
- RuleTag enum with 18 severity/category/feature tags
- ProfileXMLParser for parsing bundled XML validation profiles
- ProfileLoader actor with thread-safe caching singleton
- RuleExpression AST and ExpressionParser for rule test expressions
- RuleExpressionEvaluator with property/variable substitution
- RuleTestRunner for executing rules against PDF objects
- ProfileValidator for profile integrity checking
- ProfileDirectory actor for high-level profile queries
- 733 bundled XML profile files (PDF/A and PDF/UA standards)
- 686 tests with 91.75%+ coverage

[0.1.0]: https://github.com/intrusive-memory/SwiftVerificar-validation-profiles/releases/tag/v0.1.0
