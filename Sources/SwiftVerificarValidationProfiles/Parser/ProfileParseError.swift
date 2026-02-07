import Foundation

/// Errors that can occur during validation profile parsing.
///
/// These errors indicate problems encountered while parsing XML validation
/// profile files, ranging from XML syntax errors to missing required fields.
public enum ProfileParseError: Error, Sendable, Equatable {

    /// The XML is malformed or could not be parsed.
    ///
    /// - Parameter underlyingError: The error from the XML parser, if available.
    case invalidXML(Error?)

    /// A required element is missing from the profile.
    ///
    /// - Parameter elementName: The name of the missing element.
    case missingRequiredElement(String)

    /// An attribute value could not be parsed.
    ///
    /// - Parameters:
    ///   - attributeName: The name of the attribute.
    ///   - value: The invalid value that was found.
    case invalidAttributeValue(attributeName: String, value: String)

    /// The profile flavour is unknown or unsupported.
    ///
    /// - Parameter flavour: The flavour string that could not be parsed.
    case unknownFlavour(String)

    /// The profile data is empty or contains no content.
    case emptyProfile

    // MARK: - Equatable

    public static func == (lhs: ProfileParseError, rhs: ProfileParseError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidXML(let lhsError), .invalidXML(let rhsError)):
            // Compare by localizedDescription since Error is not Equatable
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        case (.missingRequiredElement(let lhs), .missingRequiredElement(let rhs)):
            return lhs == rhs
        case (.invalidAttributeValue(let lhsName, let lhsValue), .invalidAttributeValue(let rhsName, let rhsValue)):
            return lhsName == rhsName && lhsValue == rhsValue
        case (.unknownFlavour(let lhs), .unknownFlavour(let rhs)):
            return lhs == rhs
        case (.emptyProfile, .emptyProfile):
            return true
        default:
            return false
        }
    }
}

// MARK: - LocalizedError

extension ProfileParseError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidXML(let error):
            if let error = error {
                return "Invalid XML: \(error.localizedDescription)"
            }
            return "Invalid XML structure"
        case .missingRequiredElement(let element):
            return "Missing required element: \(element)"
        case .invalidAttributeValue(let attribute, let value):
            return "Invalid value '\(value)' for attribute '\(attribute)'"
        case .unknownFlavour(let flavour):
            return "Unknown profile flavour: \(flavour)"
        case .emptyProfile:
            return "Profile data is empty"
        }
    }
}
