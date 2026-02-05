import Foundation

/// XMLParser delegate for parsing validation profile XML files.
///
/// This class implements the `XMLParserDelegate` protocol to parse veraPDF
/// validation profile XML files. It builds a `ValidationProfile` from the
/// parsed elements using builder patterns to accumulate partial data.
///
/// ## XML Structure
/// The parser expects XML conforming to the validationProfile.xsd schema:
/// ```xml
/// <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
///     <details creator="..." created="...">
///         <name>...</name>
///         <description>...</description>
///     </details>
///     <hash>...</hash>
///     <rules>
///         <rule object="..." tags="...">
///             <id specification="..." clause="..." testNumber="..."/>
///             <description>...</description>
///             <test>...</test>
///             <error>
///                 <message>...</message>
///                 <arguments>
///                     <argument>...</argument>
///                 </arguments>
///             </error>
///             <references>
///                 <reference specification="..." clause="..."/>
///             </references>
///         </rule>
///     </rules>
///     <variables>
///         <variable name="..." object="...">
///             <defaultValue>...</defaultValue>
///         </variable>
///     </variables>
/// </profile>
/// ```
///
/// - Note: This class uses `NSObject` and `XMLParserDelegate` from Foundation's
///   XML parser, which requires reference semantics.
public final class ProfileXMLDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {

    // MARK: - Result

    /// The parsed validation profile, or nil if parsing has not completed.
    public private(set) var profile: ValidationProfile?

    /// Any error encountered during parsing.
    public private(set) var parseError: ProfileParseError?

    // MARK: - Parsing State

    /// The current element path for tracking nested elements.
    private var elementStack: [String] = []

    /// Accumulated character data for the current element.
    private var currentText: String = ""

    /// The profile flavour from the root element.
    private var flavour: PDFFlavour?

    // MARK: - Profile Details Builder

    private var detailsName: String = ""
    private var detailsDescription: String = ""
    private var detailsCreator: String = ""
    private var detailsCreated: Date = Date()

    // MARK: - Profile Hash

    private var profileHash: String?

    // MARK: - Rules Collection

    private var rules: [ValidationRule] = []

    // MARK: - Current Rule Builder

    private var currentRuleObject: String = ""
    private var currentRuleTags: Set<RuleTag> = []
    private var currentRuleIdSpec: Specification = .noStandard
    private var currentRuleIdClause: String = ""
    private var currentRuleIdTestNumber: Int = 0
    private var currentRuleDescription: String = ""
    private var currentRuleTest: String = ""
    private var currentRuleErrorMessage: String = ""
    private var currentRuleErrorArguments: [ErrorArgument] = []
    private var currentRuleReferences: [Reference] = []

    // MARK: - Current Reference Builder

    private var currentRefSpec: String = ""
    private var currentRefClause: String = ""

    // MARK: - Variables Collection

    private var variables: [ProfileVariable] = []

    // MARK: - Current Variable Builder

    private var currentVarName: String = ""
    private var currentVarObject: String = ""
    private var currentVarDefaultValue: String = ""
    private var currentVarDescription: String = ""

    // MARK: - XMLParserDelegate

    public func parserDidStartDocument(_ parser: XMLParser) {
        // Reset all state for a fresh parse
        elementStack = []
        currentText = ""
        flavour = nil
        detailsName = ""
        detailsDescription = ""
        detailsCreator = ""
        detailsCreated = Date()
        profileHash = nil
        rules = []
        variables = []
        profile = nil
        parseError = nil
    }

    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        elementStack.append(elementName)
        currentText = ""

        switch elementName {
        case "profile":
            // Extract flavour from root element
            if let flavourString = attributeDict["flavour"] {
                flavour = PDFFlavour(rawValue: flavourString)
            }

        case "details":
            // Extract creator and created date from attributes
            detailsCreator = attributeDict["creator"] ?? ""
            if let createdString = attributeDict["created"] {
                detailsCreated = parseISO8601Date(createdString) ?? Date()
            }

        case "rule":
            // Reset rule builder state
            currentRuleObject = attributeDict["object"] ?? ""
            currentRuleTags = parseTags(attributeDict["tags"])
            currentRuleIdSpec = .noStandard
            currentRuleIdClause = ""
            currentRuleIdTestNumber = 0
            currentRuleDescription = ""
            currentRuleTest = ""
            currentRuleErrorMessage = ""
            currentRuleErrorArguments = []
            currentRuleReferences = []

        case "id":
            // Extract id attributes
            if let specString = attributeDict["specification"],
               let spec = Specification(rawValue: specString) {
                currentRuleIdSpec = spec
            }
            currentRuleIdClause = attributeDict["clause"] ?? ""
            if let testNumberString = attributeDict["testNumber"],
               let testNumber = Int(testNumberString) {
                currentRuleIdTestNumber = testNumber
            }

        case "reference":
            // Extract reference attributes
            currentRefSpec = attributeDict["specification"] ?? ""
            currentRefClause = attributeDict["clause"] ?? ""

        case "variable":
            // Reset variable builder state
            currentVarName = attributeDict["name"] ?? ""
            currentVarObject = attributeDict["object"] ?? ""
            currentVarDefaultValue = ""
            currentVarDescription = ""

        default:
            break
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    public func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Determine context by checking the parent element
        let parentElement = elementStack.count > 1 ? elementStack[elementStack.count - 2] : nil

        switch elementName {
        case "name":
            if parentElement == "details" {
                detailsName = trimmedText
            }

        case "description":
            if parentElement == "details" {
                detailsDescription = trimmedText
            } else if parentElement == "rule" {
                currentRuleDescription = trimmedText
            }

        case "hash":
            profileHash = trimmedText.isEmpty ? nil : trimmedText

        case "test":
            currentRuleTest = trimmedText

        case "message":
            currentRuleErrorMessage = trimmedText

        case "argument":
            if !trimmedText.isEmpty {
                currentRuleErrorArguments.append(ErrorArgument(name: trimmedText))
            }

        case "reference":
            if !currentRefSpec.isEmpty || !currentRefClause.isEmpty {
                currentRuleReferences.append(Reference(
                    specification: currentRefSpec,
                    clause: currentRefClause
                ))
            }
            currentRefSpec = ""
            currentRefClause = ""

        case "rule":
            // Build and add the completed rule
            let ruleId = RuleID(
                specification: currentRuleIdSpec,
                clause: currentRuleIdClause,
                testNumber: currentRuleIdTestNumber
            )
            let error = ErrorDetails(
                message: currentRuleErrorMessage,
                arguments: currentRuleErrorArguments
            )
            let rule = ValidationRule(
                id: ruleId,
                object: currentRuleObject,
                description: currentRuleDescription,
                test: currentRuleTest,
                error: error,
                references: currentRuleReferences,
                tags: currentRuleTags
            )
            rules.append(rule)

        case "defaultValue":
            currentVarDefaultValue = trimmedText

        case "value":
            // Some profiles use <value> instead of <defaultValue>
            if currentVarDefaultValue.isEmpty {
                currentVarDefaultValue = trimmedText
            }

        case "variable":
            // Build and add the completed variable
            // Variable description might be in the element text content
            let description = currentVarDescription.isEmpty ? trimmedText : currentVarDescription
            let variable = ProfileVariable(
                name: currentVarName,
                defaultValue: currentVarDefaultValue,
                description: description
            )
            variables.append(variable)

        default:
            break
        }

        _ = elementStack.popLast()
        currentText = ""
    }

    public func parserDidEndDocument(_ parser: XMLParser) {
        guard let flavour = flavour else {
            parseError = .missingRequiredElement("profile@flavour")
            return
        }

        let details = ProfileDetails(
            name: detailsName,
            description: detailsDescription,
            creator: detailsCreator,
            created: detailsCreated
        )

        profile = ValidationProfile(
            details: details,
            hash: profileHash,
            rules: rules,
            variables: variables,
            flavour: flavour
        )
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseErrorValue: Error) {
        parseError = .invalidXML(parseErrorValue)
    }

    // MARK: - Private Helpers

    /// Parses a comma-separated tags string into a set of RuleTag values.
    private func parseTags(_ tagsString: String?) -> Set<RuleTag> {
        guard let tagsString = tagsString, !tagsString.isEmpty else {
            return []
        }

        var tags = Set<RuleTag>()
        let tagStrings = tagsString.split(separator: ",").map {
            String($0).trimmingCharacters(in: .whitespaces)
        }

        for tagString in tagStrings {
            if let tag = RuleTag(rawValue: tagString) {
                tags.insert(tag)
            }
        }

        return tags
    }

    /// Parses an ISO 8601 date string.
    private func parseISO8601Date(_ dateString: String) -> Date? {
        // Try ISO 8601 with fractional seconds and timezone
        let formatters: [ISO8601DateFormatter] = [
            {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }(),
            {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime]
                return formatter
            }()
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        // Fallback: try standard DateFormatter with common formats
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd"
        ]

        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }
}
