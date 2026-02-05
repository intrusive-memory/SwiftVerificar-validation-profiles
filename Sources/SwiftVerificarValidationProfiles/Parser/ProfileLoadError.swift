import Foundation

/// Errors that can occur when loading validation profiles from resources.
///
/// These errors indicate problems finding or loading bundled profile XML files,
/// distinct from parsing errors which occur when the XML content is malformed.
public enum ProfileLoadError: Error, Sendable, Equatable {

    /// The requested profile could not be found in the bundle resources.
    ///
    /// - Parameter flavour: The PDF flavour that was requested.
    case profileNotFound(PDFFlavour)

    /// The profile resource bundle is not available.
    ///
    /// This can occur if the package resources are not properly bundled
    /// or if the code is running in an environment without resource access.
    case resourceBundleUnavailable

    /// A profile file was found but could not be read.
    ///
    /// - Parameter path: The path to the file that could not be read.
    case fileReadError(String)
}

// MARK: - LocalizedError

extension ProfileLoadError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .profileNotFound(let flavour):
            return "Profile not found for flavour: \(flavour.displayName)"
        case .resourceBundleUnavailable:
            return "Profile resource bundle is not available"
        case .fileReadError(let path):
            return "Failed to read profile file: \(path)"
        }
    }
}
