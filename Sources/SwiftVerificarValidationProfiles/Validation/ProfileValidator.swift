import Foundation

/// Validates that profiles integrate correctly with the expression evaluator.
///
/// `ProfileValidator` performs integrity checks on validation profiles to ensure:
/// - All rule test expressions can be parsed
/// - Rule object types are valid
/// - Profile-level variables are well-formed
/// - Rules reference valid specifications
///
/// ## Example
/// ```swift
/// let validator = ProfileValidator()
/// let profile = try await ProfileLoader.shared.loadProfile(for: .pdfUA2)
///
/// let result = validator.validate(profile: profile)
/// if !result.isValid {
///     for issue in result.issues {
///         print("Issue: \(issue.description)")
///     }
/// }
/// ```
public struct ProfileValidator: Sendable {

    /// The expression parser used for validation.
    private let parser: ExpressionParser

    /// Creates a new profile validator.
    ///
    /// - Parameter parser: The expression parser to use (default: new instance).
    public init(parser: ExpressionParser = ExpressionParser()) {
        self.parser = parser
    }

    /// Validates a complete validation profile.
    ///
    /// - Parameter profile: The profile to validate.
    /// - Returns: A validation result with any issues found.
    public func validate(profile: ValidationProfile) -> ProfileValidationResult {
        var issues: [ProfileValidationIssue] = []

        // Validate each rule
        for rule in profile.rules {
            issues.append(contentsOf: validateRule(rule))
        }

        // Validate variables
        for variable in profile.variables {
            issues.append(contentsOf: validateVariable(variable))
        }

        // Check for duplicate rule IDs
        let ruleIDs = profile.rules.map { $0.id }
        let uniqueIDs = Set(ruleIDs)
        if ruleIDs.count != uniqueIDs.count {
            issues.append(ProfileValidationIssue(
                severity: .warning,
                category: .duplicateRuleID,
                message: "Profile contains duplicate rule IDs",
                details: "Found \(ruleIDs.count) rules but only \(uniqueIDs.count) unique IDs"
            ))
        }

        return ProfileValidationResult(
            profile: profile,
            issues: issues
        )
    }

    /// Validates a single rule.
    ///
    /// - Parameter rule: The rule to validate.
    /// - Returns: An array of validation issues found.
    private func validateRule(_ rule: ValidationRule) -> [ProfileValidationIssue] {
        var issues: [ProfileValidationIssue] = []

        // Validate test expression can be parsed
        do {
            _ = try parser.parse(rule.test)
        } catch let error as ExpressionParseError {
            issues.append(ProfileValidationIssue(
                severity: .error,
                category: .invalidExpression,
                message: "Rule \(rule.id.uniqueID) has invalid test expression",
                details: "Parse error: \(error.localizedDescription)",
                ruleID: rule.id
            ))
        } catch {
            issues.append(ProfileValidationIssue(
                severity: .error,
                category: .invalidExpression,
                message: "Rule \(rule.id.uniqueID) has invalid test expression",
                details: "Unknown error: \(error.localizedDescription)",
                ruleID: rule.id
            ))
        }

        // Check if object type is recognized
        if PDFObjectType(rawValue: rule.object) == nil {
            issues.append(ProfileValidationIssue(
                severity: .warning,
                category: .unknownObjectType,
                message: "Rule \(rule.id.uniqueID) references unknown object type",
                details: "Object type '\(rule.object)' is not defined in PDFObjectType",
                ruleID: rule.id
            ))
        }

        // Validate error message placeholders
        let placeholderPattern = "%\\d+"
        if rule.error.message.range(of: placeholderPattern, options: .regularExpression) != nil {
            let placeholderCount = rule.error.message.matches(of: placeholderPattern).count
            if placeholderCount != rule.error.arguments.count {
                issues.append(ProfileValidationIssue(
                    severity: .warning,
                    category: .argumentMismatch,
                    message: "Rule \(rule.id.uniqueID) has placeholder/argument count mismatch",
                    details: "Found \(placeholderCount) placeholders but \(rule.error.arguments.count) arguments",
                    ruleID: rule.id
                ))
            }
        }

        return issues
    }

    /// Validates a profile variable.
    ///
    /// - Parameter variable: The variable to validate.
    /// - Returns: An array of validation issues found.
    private func validateVariable(_ variable: ProfileVariable) -> [ProfileValidationIssue] {
        var issues: [ProfileValidationIssue] = []

        // Variable names should not be empty
        if variable.name.isEmpty {
            issues.append(ProfileValidationIssue(
                severity: .error,
                category: .invalidVariable,
                message: "Profile variable has empty name",
                details: "Variable: \(variable)"
            ))
        }

        // Check for reserved JavaScript keywords
        let reservedKeywords = ["null", "true", "false", "Math"]
        if reservedKeywords.contains(variable.name) {
            issues.append(ProfileValidationIssue(
                severity: .warning,
                category: .invalidVariable,
                message: "Profile variable uses reserved keyword",
                details: "Variable name '\(variable.name)' is a reserved keyword"
            ))
        }

        return issues
    }
}

/// The result of validating a profile.
public struct ProfileValidationResult: Sendable {

    /// The profile that was validated.
    public let profile: ValidationProfile

    /// Issues found during validation.
    public let issues: [ProfileValidationIssue]

    /// Whether the profile is valid (no errors, warnings allowed).
    public var isValid: Bool {
        !issues.contains { $0.severity == .error }
    }

    /// Whether the profile has any issues (errors or warnings).
    public var hasIssues: Bool {
        !issues.isEmpty
    }

    /// All error-level issues.
    public var errors: [ProfileValidationIssue] {
        issues.filter { $0.severity == .error }
    }

    /// All warning-level issues.
    public var warnings: [ProfileValidationIssue] {
        issues.filter { $0.severity == .warning }
    }

    /// Creates a new profile validation result.
    public init(profile: ValidationProfile, issues: [ProfileValidationIssue]) {
        self.profile = profile
        self.issues = issues
    }
}

/// An issue found during profile validation.
public struct ProfileValidationIssue: Sendable {

    /// The severity of the issue.
    public let severity: ProfileValidationSeverity

    /// The category of the issue.
    public let category: ProfileValidationCategory

    /// A human-readable message describing the issue.
    public let message: String

    /// Additional details about the issue.
    public let details: String?

    /// The rule ID associated with this issue, if applicable.
    public let ruleID: RuleID?

    /// Creates a new profile validation issue.
    public init(
        severity: ProfileValidationSeverity,
        category: ProfileValidationCategory,
        message: String,
        details: String? = nil,
        ruleID: RuleID? = nil
    ) {
        self.severity = severity
        self.category = category
        self.message = message
        self.details = details
        self.ruleID = ruleID
    }

    /// A formatted description of the issue.
    public var description: String {
        var result = "[\(severity.rawValue.uppercased())] \(category.rawValue): \(message)"
        if let details = details {
            result += "\n  Details: \(details)"
        }
        if let ruleID = ruleID {
            result += "\n  Rule: \(ruleID.uniqueID)"
        }
        return result
    }
}

/// The severity of a profile validation issue.
public enum ProfileValidationSeverity: String, Sendable {
    /// An error that prevents profile use.
    case error

    /// A warning that indicates potential problems.
    case warning
}

/// The category of a profile validation issue.
public enum ProfileValidationCategory: String, Sendable {
    /// Invalid test expression.
    case invalidExpression

    /// Unknown PDF object type.
    case unknownObjectType

    /// Invalid profile variable.
    case invalidVariable

    /// Duplicate rule ID.
    case duplicateRuleID

    /// Error message argument mismatch.
    case argumentMismatch
}

extension String {
    /// Helper to count regex matches.
    fileprivate func matches(of pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(startIndex..., in: self)
        let matches = regex.matches(in: self, range: range)
        return matches.compactMap { match in
            Range(match.range, in: self).map { String(self[$0]) }
        }
    }
}
