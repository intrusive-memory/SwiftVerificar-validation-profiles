import Foundation

/// Metadata about a validation profile.
///
/// Contains identifying information about a validation profile, including
/// its name, description, creator, and creation date. This corresponds to
/// the `<details>` element in the XML validation profile schema.
///
/// ## Example
/// For an XML details element like:
/// ```xml
/// <details>
///     <name>PDF/UA-2 validation profile</name>
///     <description>Validation rules for PDF/UA-2 (ISO 14289-2)</description>
///     <creator>veraPDF Consortium</creator>
///     <created>2024-01-15T00:00:00.000+00:00</created>
/// </details>
/// ```
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public struct ProfileDetails: Codable, Sendable, Hashable {

    /// The name of the validation profile.
    public let name: String

    /// A human-readable description of the profile's purpose.
    public let description: String

    /// The creator or author of the profile.
    public let creator: String

    /// The date the profile was created.
    public let created: Date

    /// Creates new profile details.
    ///
    /// - Parameters:
    ///   - name: The profile name.
    ///   - description: A description of the profile.
    ///   - creator: The profile creator.
    ///   - created: The creation date.
    public init(name: String, description: String, creator: String, created: Date) {
        self.name = name
        self.description = description
        self.creator = creator
        self.created = created
    }
}
