import Foundation

/// Parser for validation profile XML files.
///
/// `ProfileXMLParser` provides a high-level API for parsing veraPDF validation
/// profile XML files into `ValidationProfile` instances. It uses Foundation's
/// `XMLParser` with a custom delegate to handle the parsing.
///
/// ## Usage
/// ```swift
/// let parser = ProfileXMLParser()
///
/// // Parse from Data
/// let profile = try parser.parse(data: xmlData)
///
/// // Parse from URL
/// let profile = try parser.parse(contentsOf: fileURL)
/// ```
///
/// ## Thread Safety
/// `ProfileXMLParser` is a value type (struct) and is safe to use from any thread.
/// Each call to `parse` creates its own internal state and does not share
/// mutable data with other calls.
///
/// - Note: This parser uses Foundation's `XMLParser` exclusively, as required by
///   the execution plan. No third-party XML parsers are used.
public struct ProfileXMLParser: Sendable {

    /// Creates a new profile XML parser.
    public init() {}

    /// Parses a validation profile from XML data.
    ///
    /// - Parameter data: The XML data to parse.
    /// - Returns: The parsed `ValidationProfile`.
    /// - Throws: `ProfileParseError` if parsing fails.
    public func parse(data: Data) throws -> ValidationProfile {
        guard !data.isEmpty else {
            throw ProfileParseError.emptyProfile
        }

        let xmlParser = XMLParser(data: data)
        let delegate = ProfileXMLDelegate()
        xmlParser.delegate = delegate

        guard xmlParser.parse() else {
            if let error = delegate.parseError {
                throw error
            }
            throw ProfileParseError.invalidXML(xmlParser.parserError)
        }

        if let error = delegate.parseError {
            throw error
        }

        guard let profile = delegate.profile else {
            throw ProfileParseError.missingRequiredElement("profile")
        }

        return profile
    }

    /// Parses a validation profile from a file URL.
    ///
    /// - Parameter url: The URL of the XML file to parse.
    /// - Returns: The parsed `ValidationProfile`.
    /// - Throws: `ProfileParseError` if parsing fails, or a file system error
    ///   if the file cannot be read.
    public func parse(contentsOf url: URL) throws -> ValidationProfile {
        let data = try Data(contentsOf: url)
        return try parse(data: data)
    }

    /// Parses a validation profile from an XML string.
    ///
    /// - Parameter xmlString: The XML string to parse.
    /// - Returns: The parsed `ValidationProfile`.
    /// - Throws: `ProfileParseError` if parsing fails.
    public func parse(xmlString: String) throws -> ValidationProfile {
        guard let data = xmlString.data(using: .utf8) else {
            throw ProfileParseError.emptyProfile
        }
        return try parse(data: data)
    }
}
