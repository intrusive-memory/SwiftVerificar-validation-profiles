import Foundation

/// Evaluates rule test expressions against property values.
///
/// `RuleExpressionEvaluator` takes a rule test expression (either as a string
/// or a pre-parsed ``RuleExpression`` AST) and evaluates it against a dictionary
/// of property values, returning the result.
///
/// ## Example
/// ```swift
/// let evaluator = RuleExpressionEvaluator()
///
/// // Evaluate a string expression
/// let result = try evaluator.evaluate(
///     expression: "containsStructTreeRoot == true",
///     properties: ["containsStructTreeRoot": .bool(true)]
/// )
/// print(result)  // true
///
/// // Evaluate a pre-parsed expression
/// let ast = try ExpressionParser().parse("x > 5")
/// let value = try evaluator.evaluate(ast, with: ["x": .int(10)])
/// print(value.boolValue)  // true
/// ```
///
/// ## Supported Operations
/// - Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=`
/// - Logical: `&&`, `||`, `!`
/// - Arithmetic: `+`, `-`, `*`, `/`, `%`
/// - String methods: `split`, `length`, `test` (regex)
/// - Array methods: `filter`, `length`, `indexOf`
/// - Math functions: `Math.abs`, `Math.floor`, `Math.ceil`
///
/// - Note: This evaluator is thread-safe and can be used concurrently.
public struct RuleExpressionEvaluator: Sendable {
    /// Maximum evaluation depth to prevent stack overflow.
    private static let maxDepth = 100

    /// The parser used for string expressions.
    private let parser = ExpressionParser()

    /// Creates a new expression evaluator.
    public init() {}

    /// Evaluates an expression string and returns a boolean result.
    ///
    /// - Parameters:
    ///   - expression: The expression string to evaluate.
    ///   - properties: The property values to use during evaluation.
    /// - Returns: The boolean result of the expression.
    /// - Throws: ``ExpressionParseError`` or ``EvaluationError``.
    public func evaluate(
        expression: String,
        properties: [String: PropertyValue]
    ) throws -> Bool {
        let ast = try parser.parse(expression)
        let result = try evaluate(ast, with: properties)
        return result.boolValue
    }

    /// Evaluates a parsed expression AST.
    ///
    /// - Parameters:
    ///   - expression: The expression AST to evaluate.
    ///   - properties: The property values to use during evaluation.
    /// - Returns: The resulting property value.
    /// - Throws: ``EvaluationError`` if evaluation fails.
    public func evaluate(
        _ expression: RuleExpression,
        with properties: [String: PropertyValue]
    ) throws -> PropertyValue {
        try evaluate(expression, properties: properties, depth: 0, lambdaScope: [:])
    }
}

// MARK: - Internal Evaluation

extension RuleExpressionEvaluator {
    private func evaluate(
        _ expr: RuleExpression,
        properties: [String: PropertyValue],
        depth: Int,
        lambdaScope: [String: PropertyValue]
    ) throws -> PropertyValue {
        guard depth < Self.maxDepth else {
            throw EvaluationError.maxDepthExceeded(depth: depth)
        }

        switch expr {
        case .literal(let value):
            return value

        case .identifier(let name):
            // Check lambda scope first, then properties
            if let value = lambdaScope[name] {
                return value
            }
            if let value = properties[name] {
                return value
            }
            throw EvaluationError.unknownIdentifier(name: name)

        case .binary(let left, let op, let right):
            return try evaluateBinary(left, op, right, properties: properties, depth: depth, lambdaScope: lambdaScope)

        case .unary(let op, let operand):
            return try evaluateUnary(op, operand, properties: properties, depth: depth, lambdaScope: lambdaScope)

        case .call(let name, let args):
            return try evaluateCall(name, args, properties: properties, depth: depth, lambdaScope: lambdaScope)

        case .member(let object, let property):
            return try evaluateMember(object, property, properties: properties, depth: depth, lambdaScope: lambdaScope)

        case .index(let object, let index):
            return try evaluateIndex(object, index, properties: properties, depth: depth, lambdaScope: lambdaScope)

        case .ternary(let condition, let thenExpr, let elseExpr):
            let condValue = try evaluate(condition, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if condValue.boolValue {
                return try evaluate(thenExpr, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            } else {
                return try evaluate(elseExpr, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            }

        case .lambda:
            // Lambda expressions are evaluated when used as arguments
            // Return a sentinel value
            return .null

        case .regex:
            // Regex literals are used with .test() method
            return .null
        }
    }

    private func evaluateBinary(
        _ left: RuleExpression,
        _ op: BinaryOperator,
        _ right: RuleExpression,
        properties: [String: PropertyValue],
        depth: Int,
        lambdaScope: [String: PropertyValue]
    ) throws -> PropertyValue {
        // Short-circuit evaluation for logical operators
        switch op {
        case .and:
            let leftVal = try evaluate(left, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if !leftVal.boolValue {
                return .bool(false)
            }
            let rightVal = try evaluate(right, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            return .bool(rightVal.boolValue)

        case .or:
            let leftVal = try evaluate(left, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if leftVal.boolValue {
                return .bool(true)
            }
            let rightVal = try evaluate(right, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            return .bool(rightVal.boolValue)

        default:
            break
        }

        let leftVal = try evaluate(left, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
        let rightVal = try evaluate(right, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)

        switch op {
        case .eq:
            return .bool(valuesEqual(leftVal, rightVal))
        case .neq:
            return .bool(!valuesEqual(leftVal, rightVal))
        case .lt:
            return try .bool(compareValues(leftVal, rightVal) < 0)
        case .lte:
            return try .bool(compareValues(leftVal, rightVal) <= 0)
        case .gt:
            return try .bool(compareValues(leftVal, rightVal) > 0)
        case .gte:
            return try .bool(compareValues(leftVal, rightVal) >= 0)
        case .plus:
            return try addValues(leftVal, rightVal)
        case .minus:
            return try subtractValues(leftVal, rightVal)
        case .multiply:
            return try multiplyValues(leftVal, rightVal)
        case .divide:
            return try divideValues(leftVal, rightVal)
        case .modulo:
            return try moduloValues(leftVal, rightVal)
        case .and, .or:
            fatalError("Handled above")
        }
    }

    private func evaluateUnary(
        _ op: UnaryOperator,
        _ operand: RuleExpression,
        properties: [String: PropertyValue],
        depth: Int,
        lambdaScope: [String: PropertyValue]
    ) throws -> PropertyValue {
        let value = try evaluate(operand, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)

        switch op {
        case .not:
            return .bool(!value.boolValue)
        case .minus:
            if let i = value.intValue, case .int = value {
                return .int(-i)
            } else if let d = value.doubleValue {
                return .double(-d)
            }
            throw EvaluationError.typeMismatch(
                operation: "unary minus",
                expected: "number",
                found: describeType(value)
            )
        }
    }

    private func evaluateCall(
        _ name: String,
        _ args: [RuleExpression],
        properties: [String: PropertyValue],
        depth: Int,
        lambdaScope: [String: PropertyValue]
    ) throws -> PropertyValue {
        switch name {
        // String methods (receiver is first argument)
        case "split":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "split", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            let delimiter = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "split", expected: "string", found: describeType(receiver))
            }
            guard case .string(let delim) = delimiter else {
                throw EvaluationError.typeMismatch(operation: "split delimiter", expected: "string", found: describeType(delimiter))
            }
            let parts = str.components(separatedBy: delim).map { PropertyValue.string($0) }
            return .array(parts)

        case "trim":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "trim", expected: 1, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "trim", expected: "string", found: describeType(receiver))
            }
            return .string(str.trimmingCharacters(in: .whitespacesAndNewlines))

        case "toLowerCase":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "toLowerCase", expected: 1, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "toLowerCase", expected: "string", found: describeType(receiver))
            }
            return .string(str.lowercased())

        case "toUpperCase":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "toUpperCase", expected: 1, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "toUpperCase", expected: "string", found: describeType(receiver))
            }
            return .string(str.uppercased())

        case "startsWith":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "startsWith", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            let prefix = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "startsWith", expected: "string", found: describeType(receiver))
            }
            guard case .string(let pre) = prefix else {
                throw EvaluationError.typeMismatch(operation: "startsWith prefix", expected: "string", found: describeType(prefix))
            }
            return .bool(str.hasPrefix(pre))

        case "endsWith":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "endsWith", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            let suffix = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "endsWith", expected: "string", found: describeType(receiver))
            }
            guard case .string(let suf) = suffix else {
                throw EvaluationError.typeMismatch(operation: "endsWith suffix", expected: "string", found: describeType(suffix))
            }
            return .bool(str.hasSuffix(suf))

        case "contains":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "contains", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            let search = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = receiver else {
                throw EvaluationError.typeMismatch(operation: "contains", expected: "string", found: describeType(receiver))
            }
            guard case .string(let sub) = search else {
                throw EvaluationError.typeMismatch(operation: "contains search", expected: "string", found: describeType(search))
            }
            return .bool(str.contains(sub))

        case "indexOf":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "indexOf", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            let search = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)

            // String indexOf
            if case .string(let str) = receiver, case .string(let sub) = search {
                if let range = str.range(of: sub) {
                    return .int(Int64(str.distance(from: str.startIndex, to: range.lowerBound)))
                }
                return .int(-1)
            }

            // Array indexOf
            if case .array(let arr) = receiver {
                if let index = arr.firstIndex(where: { valuesEqual($0, search) }) {
                    return .int(Int64(index))
                }
                return .int(-1)
            }

            throw EvaluationError.typeMismatch(operation: "indexOf", expected: "string or array", found: describeType(receiver))

        // Regex test
        case "test":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "test", expected: 2, found: args.count)
            }
            // First arg should be the regex expression (Expression.regex)
            // Second arg is the string to test
            guard case .regex(let pattern) = args[0] else {
                throw EvaluationError.typeMismatch(operation: "test", expected: "regex", found: "expression")
            }
            let testValue = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .string(let str) = testValue else {
                throw EvaluationError.typeMismatch(operation: "test", expected: "string", found: describeType(testValue))
            }
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(str.startIndex..., in: str)
                return .bool(regex.firstMatch(in: str, options: [], range: range) != nil)
            } catch {
                throw EvaluationError.invalidRegex(pattern: pattern)
            }

        // Array methods
        case "filter":
            guard args.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(function: "filter", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .array(let arr) = receiver else {
                throw EvaluationError.typeMismatch(operation: "filter", expected: "array", found: describeType(receiver))
            }
            guard case .lambda(let param, let body) = args[1] else {
                throw EvaluationError.typeMismatch(operation: "filter predicate", expected: "lambda", found: "expression")
            }
            var result: [PropertyValue] = []
            for elem in arr {
                var scope = lambdaScope
                scope[param] = elem
                let filterResult = try evaluate(body, properties: properties, depth: depth + 1, lambdaScope: scope)
                if filterResult.boolValue {
                    result.append(elem)
                }
            }
            return .array(result)

        case "map":
            guard args.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(function: "map", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .array(let arr) = receiver else {
                throw EvaluationError.typeMismatch(operation: "map", expected: "array", found: describeType(receiver))
            }
            guard case .lambda(let param, let body) = args[1] else {
                throw EvaluationError.typeMismatch(operation: "map transform", expected: "lambda", found: "expression")
            }
            var result: [PropertyValue] = []
            for elem in arr {
                var scope = lambdaScope
                scope[param] = elem
                let mapped = try evaluate(body, properties: properties, depth: depth + 1, lambdaScope: scope)
                result.append(mapped)
            }
            return .array(result)

        case "some":
            guard args.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(function: "some", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .array(let arr) = receiver else {
                throw EvaluationError.typeMismatch(operation: "some", expected: "array", found: describeType(receiver))
            }
            guard case .lambda(let param, let body) = args[1] else {
                throw EvaluationError.typeMismatch(operation: "some predicate", expected: "lambda", found: "expression")
            }
            for elem in arr {
                var scope = lambdaScope
                scope[param] = elem
                let result = try evaluate(body, properties: properties, depth: depth + 1, lambdaScope: scope)
                if result.boolValue {
                    return .bool(true)
                }
            }
            return .bool(false)

        case "every":
            guard args.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(function: "every", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .array(let arr) = receiver else {
                throw EvaluationError.typeMismatch(operation: "every", expected: "array", found: describeType(receiver))
            }
            guard case .lambda(let param, let body) = args[1] else {
                throw EvaluationError.typeMismatch(operation: "every predicate", expected: "lambda", found: "expression")
            }
            for elem in arr {
                var scope = lambdaScope
                scope[param] = elem
                let result = try evaluate(body, properties: properties, depth: depth + 1, lambdaScope: scope)
                if !result.boolValue {
                    return .bool(false)
                }
            }
            return .bool(true)

        case "includes":
            guard args.count == 2 else {
                throw EvaluationError.invalidArgumentCount(function: "includes", expected: 2, found: args.count)
            }
            let receiver = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            let search = try evaluate(args[1], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            guard case .array(let arr) = receiver else {
                throw EvaluationError.typeMismatch(operation: "includes", expected: "array", found: describeType(receiver))
            }
            return .bool(arr.contains { valuesEqual($0, search) })

        // Math functions
        case "abs":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "abs", expected: 1, found: args.count)
            }
            let value = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if let i = value.intValue, case .int = value {
                return .int(abs(i))
            } else if let d = value.doubleValue {
                return .double(abs(d))
            }
            throw EvaluationError.typeMismatch(operation: "abs", expected: "number", found: describeType(value))

        case "floor":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "floor", expected: 1, found: args.count)
            }
            let value = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if let d = value.doubleValue {
                return .double(floor(d))
            }
            throw EvaluationError.typeMismatch(operation: "floor", expected: "number", found: describeType(value))

        case "ceil":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "ceil", expected: 1, found: args.count)
            }
            let value = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if let d = value.doubleValue {
                return .double(ceil(d))
            }
            throw EvaluationError.typeMismatch(operation: "ceil", expected: "number", found: describeType(value))

        case "round":
            guard args.count == 1 else {
                throw EvaluationError.invalidArgumentCount(function: "round", expected: 1, found: args.count)
            }
            let value = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            if let d = value.doubleValue {
                return .double(Darwin.round(d))
            }
            throw EvaluationError.typeMismatch(operation: "round", expected: "number", found: describeType(value))

        case "min":
            guard args.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(function: "min", expected: 2, found: args.count)
            }
            var minVal = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            for arg in args.dropFirst() {
                let val = try evaluate(arg, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
                if try compareValues(val, minVal) < 0 {
                    minVal = val
                }
            }
            return minVal

        case "max":
            guard args.count >= 2 else {
                throw EvaluationError.invalidArgumentCount(function: "max", expected: 2, found: args.count)
            }
            var maxVal = try evaluate(args[0], properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
            for arg in args.dropFirst() {
                let val = try evaluate(arg, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
                if try compareValues(val, maxVal) > 0 {
                    maxVal = val
                }
            }
            return maxVal

        default:
            throw EvaluationError.unknownFunction(name: name)
        }
    }

    private func evaluateMember(
        _ object: RuleExpression,
        _ property: String,
        properties: [String: PropertyValue],
        depth: Int,
        lambdaScope: [String: PropertyValue]
    ) throws -> PropertyValue {
        // Handle Math.xxx as function calls
        if case .identifier("Math") = object {
            // Return identifier for later function call
            throw EvaluationError.unknownIdentifier(name: "Math.\(property)")
        }

        let objValue = try evaluate(object, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)

        switch property {
        case "length":
            if case .string(let str) = objValue {
                return .int(Int64(str.count))
            }
            if case .array(let arr) = objValue {
                return .int(Int64(arr.count))
            }
            throw EvaluationError.typeMismatch(operation: "length", expected: "string or array", found: describeType(objValue))

        default:
            throw EvaluationError.unknownIdentifier(name: property)
        }
    }

    private func evaluateIndex(
        _ object: RuleExpression,
        _ index: RuleExpression,
        properties: [String: PropertyValue],
        depth: Int,
        lambdaScope: [String: PropertyValue]
    ) throws -> PropertyValue {
        let objValue = try evaluate(object, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)
        let indexValue = try evaluate(index, properties: properties, depth: depth + 1, lambdaScope: lambdaScope)

        guard let idx = indexValue.intValue else {
            throw EvaluationError.typeMismatch(operation: "index", expected: "integer", found: describeType(indexValue))
        }

        switch objValue {
        case .array(let arr):
            guard idx >= 0 && Int(idx) < arr.count else {
                throw EvaluationError.indexOutOfBounds(index: Int(idx), count: arr.count)
            }
            return arr[Int(idx)]

        case .string(let str):
            guard idx >= 0 && Int(idx) < str.count else {
                throw EvaluationError.indexOutOfBounds(index: Int(idx), count: str.count)
            }
            let charIndex = str.index(str.startIndex, offsetBy: Int(idx))
            return .string(String(str[charIndex]))

        default:
            throw EvaluationError.typeMismatch(operation: "index access", expected: "array or string", found: describeType(objValue))
        }
    }
}

// MARK: - Value Operations

extension RuleExpressionEvaluator {
    private func valuesEqual(_ lhs: PropertyValue, _ rhs: PropertyValue) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case (.bool(let a), .bool(let b)):
            return a == b
        case (.int(let a), .int(let b)):
            return a == b
        case (.int(let a), .double(let b)):
            return Double(a) == b
        case (.double(let a), .int(let b)):
            return a == Double(b)
        case (.double(let a), .double(let b)):
            return a == b
        case (.string(let a), .string(let b)):
            return a == b
        case (.array(let a), .array(let b)):
            guard a.count == b.count else { return false }
            for (ae, be) in zip(a, b) {
                if !valuesEqual(ae, be) { return false }
            }
            return true
        default:
            return false
        }
    }

    private func compareValues(_ lhs: PropertyValue, _ rhs: PropertyValue) throws -> Int {
        switch (lhs, rhs) {
        case (.int(let a), .int(let b)):
            return a < b ? -1 : (a > b ? 1 : 0)
        case (.int(let a), .double(let b)):
            let ad = Double(a)
            return ad < b ? -1 : (ad > b ? 1 : 0)
        case (.double(let a), .int(let b)):
            let bd = Double(b)
            return a < bd ? -1 : (a > bd ? 1 : 0)
        case (.double(let a), .double(let b)):
            return a < b ? -1 : (a > b ? 1 : 0)
        case (.string(let a), .string(let b)):
            return a < b ? -1 : (a > b ? 1 : 0)
        default:
            throw EvaluationError.typeMismatch(
                operation: "comparison",
                expected: "comparable types",
                found: "\(describeType(lhs)) and \(describeType(rhs))"
            )
        }
    }

    private func addValues(_ lhs: PropertyValue, _ rhs: PropertyValue) throws -> PropertyValue {
        switch (lhs, rhs) {
        case (.int(let a), .int(let b)):
            return .int(a + b)
        case (.int(let a), .double(let b)):
            return .double(Double(a) + b)
        case (.double(let a), .int(let b)):
            return .double(a + Double(b))
        case (.double(let a), .double(let b)):
            return .double(a + b)
        case (.string(let a), .string(let b)):
            return .string(a + b)
        case (.string(let a), _):
            return .string(a + rhs.stringValue)
        case (_, .string(let b)):
            return .string(lhs.stringValue + b)
        default:
            throw EvaluationError.typeMismatch(
                operation: "addition",
                expected: "numbers or strings",
                found: "\(describeType(lhs)) and \(describeType(rhs))"
            )
        }
    }

    private func subtractValues(_ lhs: PropertyValue, _ rhs: PropertyValue) throws -> PropertyValue {
        switch (lhs, rhs) {
        case (.int(let a), .int(let b)):
            return .int(a - b)
        case (.int(let a), .double(let b)):
            return .double(Double(a) - b)
        case (.double(let a), .int(let b)):
            return .double(a - Double(b))
        case (.double(let a), .double(let b)):
            return .double(a - b)
        default:
            throw EvaluationError.typeMismatch(
                operation: "subtraction",
                expected: "numbers",
                found: "\(describeType(lhs)) and \(describeType(rhs))"
            )
        }
    }

    private func multiplyValues(_ lhs: PropertyValue, _ rhs: PropertyValue) throws -> PropertyValue {
        switch (lhs, rhs) {
        case (.int(let a), .int(let b)):
            return .int(a * b)
        case (.int(let a), .double(let b)):
            return .double(Double(a) * b)
        case (.double(let a), .int(let b)):
            return .double(a * Double(b))
        case (.double(let a), .double(let b)):
            return .double(a * b)
        default:
            throw EvaluationError.typeMismatch(
                operation: "multiplication",
                expected: "numbers",
                found: "\(describeType(lhs)) and \(describeType(rhs))"
            )
        }
    }

    private func divideValues(_ lhs: PropertyValue, _ rhs: PropertyValue) throws -> PropertyValue {
        // Check for division by zero
        if let rhsInt = rhs.intValue, rhsInt == 0 {
            throw EvaluationError.divisionByZero
        }
        if let rhsDouble = rhs.doubleValue, rhsDouble == 0 {
            throw EvaluationError.divisionByZero
        }

        switch (lhs, rhs) {
        case (.int(let a), .int(let b)):
            return .int(a / b)
        case (.int(let a), .double(let b)):
            return .double(Double(a) / b)
        case (.double(let a), .int(let b)):
            return .double(a / Double(b))
        case (.double(let a), .double(let b)):
            return .double(a / b)
        default:
            throw EvaluationError.typeMismatch(
                operation: "division",
                expected: "numbers",
                found: "\(describeType(lhs)) and \(describeType(rhs))"
            )
        }
    }

    private func moduloValues(_ lhs: PropertyValue, _ rhs: PropertyValue) throws -> PropertyValue {
        // Check for division by zero
        if let rhsInt = rhs.intValue, rhsInt == 0 {
            throw EvaluationError.divisionByZero
        }
        if let rhsDouble = rhs.doubleValue, rhsDouble == 0 {
            throw EvaluationError.divisionByZero
        }

        switch (lhs, rhs) {
        case (.int(let a), .int(let b)):
            return .int(a % b)
        case (.int(let a), .double(let b)):
            return .double(Double(a).truncatingRemainder(dividingBy: b))
        case (.double(let a), .int(let b)):
            return .double(a.truncatingRemainder(dividingBy: Double(b)))
        case (.double(let a), .double(let b)):
            return .double(a.truncatingRemainder(dividingBy: b))
        default:
            throw EvaluationError.typeMismatch(
                operation: "modulo",
                expected: "numbers",
                found: "\(describeType(lhs)) and \(describeType(rhs))"
            )
        }
    }

    private func describeType(_ value: PropertyValue) -> String {
        switch value {
        case .null: return "null"
        case .bool: return "boolean"
        case .int: return "integer"
        case .double: return "double"
        case .string: return "string"
        case .array: return "array"
        }
    }
}
