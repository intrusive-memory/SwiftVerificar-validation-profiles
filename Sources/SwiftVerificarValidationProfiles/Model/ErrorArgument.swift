import Foundation

/// An argument referenced in an error message template.
///
/// Error messages in validation profiles use placeholder syntax like `%1`, `%2`
/// to reference property values from the validated object. Each `ErrorArgument`
/// names the property whose value should be substituted at the corresponding
/// placeholder position.
///
/// ## Example
/// For an error message `"Font %1 is not embedded"` with argument `name: "fontName"`,
/// the runtime evaluator would substitute the object's `fontName` property value
/// for `%1` in the rendered error message.
///
/// Corresponds to the `<argument>` element in the XML validation profiles.
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public struct ErrorArgument: Codable, Sendable, Hashable {

    /// The name of the property whose value should be substituted into the error message.
    public let name: String

    /// Creates a new error argument.
    ///
    /// - Parameter name: The property name to reference in the error message.
    public init(name: String) {
        self.name = name
    }
}
