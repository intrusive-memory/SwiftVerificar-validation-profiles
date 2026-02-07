import Foundation

/// Error details for a failed validation rule.
///
/// When a validation rule's test expression evaluates to `false`, the `ErrorDetails`
/// provide a human-readable error message describing the failure. The message may
/// contain placeholder tokens (`%1`, `%2`, etc.) that are substituted at runtime
/// with the values of the corresponding ``ErrorArgument`` properties.
///
/// ## Example
/// For an XML error element like:
/// ```xml
/// <error>
///     <message>Font %1 is not embedded and not one of the 14 standard fonts</message>
///     <arguments>
///         <argument>fontName</argument>
///     </arguments>
/// </error>
/// ```
/// The corresponding `ErrorDetails` would be:
/// ```swift
/// ErrorDetails(
///     message: "Font %1 is not embedded and not one of the 14 standard fonts",
///     arguments: [ErrorArgument(name: "fontName")]
/// )
/// ```
///
/// - Note: This is a shared type consumed by validation-profiles, validation, and biblioteca packages.
public struct ErrorDetails: Codable, Sendable, Hashable {

    /// The error message template, which may contain `%1`, `%2` placeholders.
    public let message: String

    /// The arguments whose values should be substituted into the message placeholders.
    public let arguments: [ErrorArgument]

    /// Creates new error details.
    ///
    /// - Parameters:
    ///   - message: The error message template.
    ///   - arguments: The arguments for placeholder substitution.
    public init(message: String, arguments: [ErrorArgument] = []) {
        self.message = message
        self.arguments = arguments
    }

    /// Formats the error message by substituting argument values.
    ///
    /// Each `%N` placeholder in the message is replaced with the corresponding
    /// value from the `values` dictionary, looked up by the argument's name.
    ///
    /// - Parameter values: A dictionary mapping argument names to their string values.
    /// - Returns: The formatted error message with all placeholders substituted.
    public func formattedMessage(with values: [String: String]) -> String {
        var result = message
        for (index, argument) in arguments.enumerated() {
            let placeholder = "%\(index + 1)"
            let value = values[argument.name] ?? "<unknown>"
            result = result.replacingOccurrences(of: placeholder, with: value)
        }
        return result
    }
}
