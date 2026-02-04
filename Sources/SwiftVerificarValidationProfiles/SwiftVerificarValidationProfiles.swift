import Foundation

/// SwiftVerificarValidationProfiles - Validation profiles for SwiftVerificar
///
/// Swift port of veraPDF-validation-profiles providing XML validation rules
/// for PDF/A and PDF/UA standards.
///
/// - SeeAlso: [veraPDF-validation-profiles](https://github.com/veraPDF/veraPDF-validation-profiles)
public struct SwiftVerificarValidationProfiles {

    /// The current version of the library
    public static let version = "0.1.0"

    /// Creates a new instance of SwiftVerificarValidationProfiles
    public init() {}
}

// MARK: - Profile Types

/// Available validation profile types
public enum ProfileType: String, CaseIterable, Sendable {
    // PDF/UA profiles
    case pdfUA1 = "PDF_UA-1"
    case pdfUA2 = "PDF_UA-2"

    // PDF/A-1 profiles
    case pdfA1a = "PDF_A-1a"
    case pdfA1b = "PDF_A-1b"

    // PDF/A-2 profiles
    case pdfA2a = "PDF_A-2a"
    case pdfA2b = "PDF_A-2b"
    case pdfA2u = "PDF_A-2u"

    // PDF/A-3 profiles
    case pdfA3a = "PDF_A-3a"
    case pdfA3b = "PDF_A-3b"
    case pdfA3u = "PDF_A-3u"

    // PDF/A-4 profiles
    case pdfA4 = "PDF_A-4"
    case pdfA4e = "PDF_A-4e"
    case pdfA4f = "PDF_A-4f"

    /// Human-readable name for the profile
    public var displayName: String {
        switch self {
        case .pdfUA1: return "PDF/UA-1 (ISO 14289-1)"
        case .pdfUA2: return "PDF/UA-2 (ISO 14289-2:2024)"
        case .pdfA1a: return "PDF/A-1a (ISO 19005-1 Level A)"
        case .pdfA1b: return "PDF/A-1b (ISO 19005-1 Level B)"
        case .pdfA2a: return "PDF/A-2a (ISO 19005-2 Level A)"
        case .pdfA2b: return "PDF/A-2b (ISO 19005-2 Level B)"
        case .pdfA2u: return "PDF/A-2u (ISO 19005-2 Level U)"
        case .pdfA3a: return "PDF/A-3a (ISO 19005-3 Level A)"
        case .pdfA3b: return "PDF/A-3b (ISO 19005-3 Level B)"
        case .pdfA3u: return "PDF/A-3u (ISO 19005-3 Level U)"
        case .pdfA4: return "PDF/A-4 (ISO 19005-4)"
        case .pdfA4e: return "PDF/A-4e (ISO 19005-4 Engineering)"
        case .pdfA4f: return "PDF/A-4f (ISO 19005-4 File)"
        }
    }

    /// Whether this is a PDF/UA (accessibility) profile
    public var isAccessibilityProfile: Bool {
        switch self {
        case .pdfUA1, .pdfUA2: return true
        default: return false
        }
    }

    /// Whether this is a PDF/A (archival) profile
    public var isArchivalProfile: Bool {
        !isAccessibilityProfile
    }
}

// MARK: - Profile Loader

/// Loads validation profiles from bundled XML resources
public actor ProfileLoader {

    public init() {}

    /// Load a validation profile by type
    public func loadProfile(_ type: ProfileType) async throws -> XMLProfile {
        // Placeholder - will load from bundled XML resources
        throw ProfileError.notImplemented
    }

    /// List all available profiles
    public func availableProfiles() -> [ProfileType] {
        ProfileType.allCases
    }
}

// MARK: - XML Profile Model

/// A validation profile loaded from XML
public struct XMLProfile: Sendable {
    public let name: String
    public let description: String
    public let rules: [XMLRule]
}

/// A validation rule from the XML profile
public struct XMLRule: Sendable, Identifiable {
    public let id: String
    public let specification: String
    public let clause: String
    public let testNumber: Int
    public let description: String
    public let object: String
    public let test: String
    public let errorMessage: String
    public let errorArguments: [String]
}

// MARK: - Errors

/// Errors that can occur when loading profiles
public enum ProfileError: Error {
    case profileNotFound(ProfileType)
    case invalidProfileXML(String)
    case notImplemented
}
