import Foundation

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
/// - Profile-level variables and error details
///
/// ## Usage
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
/// - SeeAlso: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
public struct SwiftVerificarValidationProfiles: Sendable {

    /// The current version of the library
    public static let version = "0.1.0"

    /// Creates a new instance of SwiftVerificarValidationProfiles
    public init() {}
}
