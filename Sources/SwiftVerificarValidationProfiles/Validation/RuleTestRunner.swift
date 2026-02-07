import Foundation

/// Executes validation rule tests against PDF objects.
///
/// `RuleTestRunner` takes a validation rule and a context containing object properties,
/// evaluates the rule's test expression, and returns the result.
///
/// ## Example
/// ```swift
/// let rule = ValidationRule(
///     id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
///     object: "PDDocument",
///     description: "Document must contain StructTreeRoot",
///     test: "containsStructTreeRoot == true",
///     error: ErrorDetails(message: "Missing StructTreeRoot"),
///     references: [],
///     tags: []
/// )
///
/// let context = ValidationContext(
///     objectType: .pdDocument,
///     properties: ["containsStructTreeRoot": .bool(true)]
/// )
///
/// let runner = RuleTestRunner()
/// let result = try runner.run(rule: rule, context: context)
/// print(result.passed)  // true
/// ```
public struct RuleTestRunner: Sendable {

    /// The expression evaluator used to test rules.
    private let evaluator: RuleExpressionEvaluator

    /// Creates a new rule test runner.
    ///
    /// - Parameter evaluator: The expression evaluator to use (default: new instance).
    public init(evaluator: RuleExpressionEvaluator = RuleExpressionEvaluator()) {
        self.evaluator = evaluator
    }

    /// Runs a validation rule test against a context.
    ///
    /// - Parameters:
    ///   - rule: The rule to test.
    ///   - context: The validation context containing object properties.
    /// - Returns: The test result.
    /// - Throws: ``RuleTestError`` if the test cannot be evaluated.
    public func run(
        rule: ValidationRule,
        context: ValidationContext
    ) throws -> RuleTestResult {
        // Verify the rule's object type matches the context
        guard rule.object == context.objectType.rawValue else {
            throw RuleTestError.objectTypeMismatch(
                ruleObject: rule.object,
                contextObject: context.objectType.rawValue
            )
        }

        do {
            let passed = try evaluator.evaluate(
                expression: rule.test,
                properties: context.allProperties
            )

            return RuleTestResult(
                rule: rule,
                passed: passed,
                error: passed ? nil : rule.error
            )
        } catch let error as ExpressionParseError {
            throw RuleTestError.parseError(rule: rule.id, error: error)
        } catch let error as EvaluationError {
            throw RuleTestError.evaluationError(rule: rule.id, error: error)
        } catch {
            throw RuleTestError.unknownError(rule: rule.id, error: error)
        }
    }

    /// Runs multiple validation rules against a context.
    ///
    /// - Parameters:
    ///   - rules: The rules to test.
    ///   - context: The validation context.
    /// - Returns: An array of test results, one per rule.
    /// - Throws: ``RuleTestError`` if any test cannot be evaluated.
    public func run(
        rules: [ValidationRule],
        context: ValidationContext
    ) throws -> [RuleTestResult] {
        try rules.map { try run(rule: $0, context: context) }
    }
}

/// The result of running a validation rule test.
public struct RuleTestResult: Sendable {

    /// The rule that was tested.
    public let rule: ValidationRule

    /// Whether the rule test passed (true) or failed (false).
    public let passed: Bool

    /// The error details if the test failed, nil if it passed.
    public let error: ErrorDetails?

    /// Creates a new rule test result.
    ///
    /// - Parameters:
    ///   - rule: The rule that was tested.
    ///   - passed: Whether the test passed.
    ///   - error: Error details if the test failed.
    public init(rule: ValidationRule, passed: Bool, error: ErrorDetails?) {
        self.rule = rule
        self.passed = passed
        self.error = error
    }

    /// A human-readable description of the result.
    public var description: String {
        if passed {
            return "PASS: \(rule.id.uniqueID) - \(rule.description)"
        } else {
            return "FAIL: \(rule.id.uniqueID) - \(error?.message ?? rule.error.message)"
        }
    }
}

/// Errors that can occur when running rule tests.
public enum RuleTestError: Error, Sendable {

    /// The rule's object type does not match the context's object type.
    case objectTypeMismatch(ruleObject: String, contextObject: String)

    /// The rule's test expression failed to parse.
    case parseError(rule: RuleID, error: ExpressionParseError)

    /// The rule's test expression failed to evaluate.
    case evaluationError(rule: RuleID, error: EvaluationError)

    /// An unknown error occurred.
    case unknownError(rule: RuleID, error: Error)
}

extension RuleTestError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .objectTypeMismatch(let ruleObject, let contextObject):
            return "Object type mismatch: rule expects '\(ruleObject)' but context has '\(contextObject)'"
        case .parseError(let rule, let error):
            return "Parse error in rule \(rule.uniqueID): \(error)"
        case .evaluationError(let rule, let error):
            return "Evaluation error in rule \(rule.uniqueID): \(error)"
        case .unknownError(let rule, let error):
            return "Unknown error in rule \(rule.uniqueID): \(error)"
        }
    }
}
