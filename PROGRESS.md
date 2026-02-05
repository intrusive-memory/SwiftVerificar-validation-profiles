# SwiftVerificar-validation-profiles Progress

## Current State
- Last completed sprint: 5
- Last commit hash: 9b52d95
- Build status: passing
- Total test count: 616
- Cumulative coverage: 97%+

## Completed Sprints
- Sprint 1: XML Profile Import -- 0 types, 5 tests, 733 XML files + 1 XSD schema imported
- Sprint 2: Core Enums -- 4 types, 98 new tests in 4 files (103 total)
- Sprint 3: Profile Model Types -- 8 types, 93 new tests in 8 files (196 total)
- Sprint 4: XML Parser -- 5 types, 100 new tests in 5 files (296 total)
- Sprint 5: Rule Expression Evaluator -- 9 types, 320 new tests in 9 files (616 total)

## Next Sprint
- Sprint 6: TBD (end of validation-profiles scope)

## Files Created (cumulative)
### Sources
- Sources/SwiftVerificarValidationProfiles/SwiftVerificarValidationProfiles.swift
- Sources/SwiftVerificarValidationProfiles/Model/PDFFlavour.swift
- Sources/SwiftVerificarValidationProfiles/Model/Specification.swift
- Sources/SwiftVerificarValidationProfiles/Model/PDFObjectType.swift
- Sources/SwiftVerificarValidationProfiles/Model/RuleTag.swift
- Sources/SwiftVerificarValidationProfiles/Model/RuleID.swift
- Sources/SwiftVerificarValidationProfiles/Model/ErrorArgument.swift
- Sources/SwiftVerificarValidationProfiles/Model/ErrorDetails.swift
- Sources/SwiftVerificarValidationProfiles/Model/Reference.swift
- Sources/SwiftVerificarValidationProfiles/Model/ProfileVariable.swift
- Sources/SwiftVerificarValidationProfiles/Model/ProfileDetails.swift
- Sources/SwiftVerificarValidationProfiles/Model/ValidationRule.swift
- Sources/SwiftVerificarValidationProfiles/Model/ValidationProfile.swift
- Sources/SwiftVerificarValidationProfiles/Parser/ProfileParseError.swift
- Sources/SwiftVerificarValidationProfiles/Parser/ProfileLoadError.swift
- Sources/SwiftVerificarValidationProfiles/Parser/ProfileXMLParser.swift
- Sources/SwiftVerificarValidationProfiles/Parser/ProfileXMLDelegate.swift
- Sources/SwiftVerificarValidationProfiles/Parser/ProfileLoader.swift
- Sources/SwiftVerificarValidationProfiles/Expression/RuleExpression.swift
- Sources/SwiftVerificarValidationProfiles/Expression/PropertyValue.swift
- Sources/SwiftVerificarValidationProfiles/Expression/BinaryOperator.swift
- Sources/SwiftVerificarValidationProfiles/Expression/UnaryOperator.swift
- Sources/SwiftVerificarValidationProfiles/Expression/ExpressionToken.swift
- Sources/SwiftVerificarValidationProfiles/Expression/ExpressionParseError.swift
- Sources/SwiftVerificarValidationProfiles/Expression/ExpressionParser.swift
- Sources/SwiftVerificarValidationProfiles/Expression/EvaluationError.swift
- Sources/SwiftVerificarValidationProfiles/Expression/RuleExpressionEvaluator.swift
- Sources/SwiftVerificarValidationProfiles/Resources/Profiles/validationProfile.xsd
- Sources/SwiftVerificarValidationProfiles/Resources/Profiles/PDF_UA/ (307 XML files)
  - PDFUA-2.xml (consolidated PDF/UA-2 profile)
  - PDFUA-1.xml (consolidated PDF/UA-1 profile)
  - WCAG-2-2.xml (WCAG 2.2 profile)
  - WCAG-2-2-Complete.xml, WCAG-2-2-Complete-PDF20.xml
  - WCAG-2-2-Machine.xml, WCAG-2-2-Machine-PDF20.xml
  - WCAG-2-2-Dev.xml
  - PDFUA-2-ISO32005.xml
  - ISO-32000-1-Tagged.xml, ISO-32000-2-Tagged.xml, ISO-32005-Tagged.xml
  - WTPDF-1-0-Accessibility.xml, WTPDF-1-0-Reuse.xml
  - 2/ (91 individual PDF/UA-2 rule files)
  - 1/ (106 individual PDF/UA-1 rule files)
  - WCAG/ (94 individual WCAG rule files)
  - WTPDF/ (additional WTPDF rule files)
- Sources/SwiftVerificarValidationProfiles/Resources/Profiles/PDF_A/ (426 XML files)
  - PDFA-1A.xml, PDFA-1B.xml (PDF/A-1 consolidated profiles)
  - PDFA-2A.xml, PDFA-2B.xml, PDFA-2U.xml (PDF/A-2 consolidated profiles)
  - PDFA-3A.xml, PDFA-3B.xml, PDFA-3U.xml (PDF/A-3 consolidated profiles)
  - PDFA-4.xml, PDFA-4E.xml, PDFA-4F.xml (PDF/A-4 consolidated profiles)
  - 1a/, 1b/, 2a/, 2b/, 2u/, 3a/, 3b/, 3u/, 4/, 4e/, 4f/ (individual rule files)

### Tests
- Tests/SwiftVerificarValidationProfilesTests/SwiftVerificarValidationProfilesTests.swift
- Tests/SwiftVerificarValidationProfilesTests/PDFFlavourTests.swift
- Tests/SwiftVerificarValidationProfilesTests/SpecificationTests.swift
- Tests/SwiftVerificarValidationProfilesTests/PDFObjectTypeTests.swift
- Tests/SwiftVerificarValidationProfilesTests/RuleTagTests.swift
- Tests/SwiftVerificarValidationProfilesTests/RuleIDTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ErrorArgumentTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ErrorDetailsTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ReferenceTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileVariableTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileDetailsTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ValidationRuleTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ValidationProfileTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileParseErrorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileLoadErrorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileXMLParserTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileXMLDelegateTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ProfileLoaderTests.swift
- Tests/SwiftVerificarValidationProfilesTests/PropertyValueTests.swift
- Tests/SwiftVerificarValidationProfilesTests/BinaryOperatorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/UnaryOperatorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ExpressionTokenTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ExpressionParseErrorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ExpressionParserTests.swift
- Tests/SwiftVerificarValidationProfilesTests/EvaluationErrorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/RuleExpressionEvaluatorTests.swift
- Tests/SwiftVerificarValidationProfilesTests/ExpressionTests.swift

## Cross-Package Needs
- (none)

## Notes
- XML profiles downloaded from https://github.com/veraPDF/veraPDF-validation-profiles (integration branch)
- Source repo license: Creative Commons Attribution 4.0 International (CC BY 4.0)
- Only XML rule files and XSD schema imported; no Java source, build files, or other artifacts
- Package.swift already configured with resources: [.copy("Resources/Profiles")] -- no changes needed
- Priority order followed: PDF/UA-2 (91 files), PDF/UA-1 (106 files), WCAG-2-2 (94 files), then PDF/A (426 files)
- Sprint 2: PDFObjectType has 188 cases matching TODO.md Section 2.4 exactly (COS: 23, PD: 68, Operators: 2, External: 6, XMP: 9, SE: 54, SA: 26)
- Sprint 2: All new source files have 100% code coverage; overall target coverage is 97%
- Sprint 3: All 8 new model types have 100% code coverage; overall target coverage is 97.77%
- Sprint 3: ValidationProfile includes convenience methods for filtering rules by object type and tags
- Sprint 3: ErrorDetails includes formattedMessage(with:) for placeholder substitution in error messages
- Sprint 4: XML Parser types use Foundation XMLParser exclusively (no third-party parsers)
- Sprint 4: ProfileLoader is a singleton actor with caching for efficient repeated profile access
- Sprint 4: ProfileXMLDelegate handles full XML validation profile parsing including rules, variables, tags, references
- Sprint 4: All new parser types have 100% code coverage; 100 new tests added across 5 test files
- Sprint 4: Removed obsolete stub types (ProfileType, old ProfileLoader, XMLProfile, XMLRule, ProfileError) from main module file
- Sprint 5: RuleExpression (renamed from Expression to avoid Swift 6 Foundation.Expression conflict) is the AST node type
- Sprint 5: ExpressionParser implements recursive descent parsing with operator precedence for JavaScript-like expressions
- Sprint 5: RuleExpressionEvaluator evaluates expressions with support for string methods, array operations, and Math functions
- Sprint 5: PropertyValue enum represents runtime values (null, bool, int, double, string, array) for expression evaluation
- Sprint 5: All 9 expression types have 100% code coverage; 320 new tests added across 9 test files
- Sprint 5: Fixed naming collision with Foundation.Expression in Swift 6 by renaming to RuleExpression throughout
- Sprint 5: Parser correctly distinguishes between negative literals (-5) and unary minus expressions (-x)
