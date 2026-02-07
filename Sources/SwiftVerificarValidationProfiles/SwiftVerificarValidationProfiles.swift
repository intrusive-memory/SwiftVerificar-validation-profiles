import Foundation

// MARK: - Type Exports to Avoid Module/Struct Name Collision

/// Expression property value type used in rule evaluation.
/// This export avoids the module/struct name collision when importing from validation package.
/// - SeeAlso: ``PropertyValue``
public typealias ExpressionPropertyValue = PropertyValue

/// SwiftVerificarValidationProfiles - Validation profiles for SwiftVerificar
///
/// Swift port of veraPDF-validation-profiles providing XML validation rules
/// for PDF/A, PDF/UA, and WCAG standards.
///
/// ## Overview
/// This package provides:
/// - Model types for validation profiles and rules (``ValidationProfile``, ``ValidationRule``)
/// - Enums for PDF flavours and specifications (``PDFFlavour``, ``Specification``)
/// - XML parsing for bundled profile files (``ProfileXMLParser``, ``ProfileLoader``)
/// - Rule expression evaluation (``RuleExpressionEvaluator``, ``PropertyValue``)
/// - Profile validation and testing (``ProfileValidator``, ``RuleTestRunner``)
/// - High-level directory service (``ProfileDirectory``)
///
/// ## Basic Usage
/// ```swift
/// import SwiftVerificarValidationProfiles
///
/// // Load a profile using the ProfileLoader
/// let loader = ProfileLoader.shared
/// let profile = try await loader.loadProfile(for: .pdfUA2)
///
/// // Query rules by object type
/// let documentRules = profile.rules(for: .pdDocument)
///
/// // Query rules by tag
/// let machineRules = profile.rules(withAllTags: [.machine])
/// ```
///
/// ## Advanced Usage
/// ```swift
/// // Use ProfileDirectory for high-level queries
/// let directory = ProfileDirectory.shared
/// let rules = try await directory.rules(for: .pdDocument, in: .pdfUA2)
/// let stats = try await directory.statistics(for: .pdfUA2)
///
/// // Evaluate rules against PDF objects
/// let context = ValidationContext(
///     objectType: .pdDocument,
///     properties: ["containsStructTreeRoot": .bool(true)]
/// )
/// let runner = RuleTestRunner()
/// let results = try runner.run(rules: rules, context: context)
///
/// // Validate profile integrity
/// let validator = ProfileValidator()
/// let issues = try await validator.validate(profile: profile)
/// ```
///
/// - SeeAlso: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
public struct SwiftVerificarValidationProfiles: Sendable {

    /// The current version of the library
    public static let version = "0.1.0"

    /// Creates a new instance of SwiftVerificarValidationProfiles
    public init() {}
}

// MARK: - Convenience Type Aliases
// All types are already public in their respective files.
// This section documents the key entry points for the package.

/// Entry point for loading validation profiles.
/// - SeeAlso: ``ProfileLoader``
public typealias Loader = ProfileLoader

/// Entry point for high-level profile queries and statistics.
/// - SeeAlso: ``ProfileDirectory``
public typealias Directory = ProfileDirectory

/// Entry point for validating rule expressions against PDF objects.
/// - SeeAlso: ``RuleTestRunner``
public typealias Runner = RuleTestRunner

/// Entry point for checking profile integrity.
/// - SeeAlso: ``ProfileValidator``
public typealias Validator = ProfileValidator
