import Foundation

/// Property value types for rule expression evaluation.
///
/// `PropertyValue` represents the possible value types that can appear in
/// rule test expressions. It supports null, boolean, numeric, string, and
/// array values, with automatic truthiness evaluation.
///
/// ## Example
/// ```swift
/// let value = PropertyValue.string("hello")
/// print(value.boolValue) // true (non-empty string is truthy)
///
/// let empty = PropertyValue.string("")
/// print(empty.boolValue) // false (empty string is falsy)
/// ```
///
/// ## Truthiness Rules
/// The ``boolValue`` property follows JavaScript-like truthiness:
/// - `null` is falsy
/// - `bool(false)` is falsy, `bool(true)` is truthy
/// - `int(0)` is falsy, other integers are truthy
/// - `double(0.0)` is falsy, other doubles are truthy (NaN is falsy)
/// - Empty strings are falsy, non-empty strings are truthy
/// - Empty arrays are falsy, non-empty arrays are truthy
///
/// - Note: This type is used by ``RuleExpressionEvaluator`` to evaluate
///   validation rule test expressions.
public enum PropertyValue: Sendable, Hashable {
    /// A null/nil value.
    case null

    /// A boolean value.
    case bool(Bool)

    /// A 64-bit integer value.
    case int(Int64)

    /// A double-precision floating point value.
    case double(Double)

    /// A string value.
    case string(String)

    /// An array of property values.
    case array([PropertyValue])

    /// The boolean interpretation of this value (truthiness).
    ///
    /// Follows JavaScript-like truthiness rules:
    /// - `null` is `false`
    /// - `bool` returns the boolean value
    /// - `int` is `false` if zero, `true` otherwise
    /// - `double` is `false` if zero or NaN, `true` otherwise
    /// - `string` is `false` if empty, `true` otherwise
    /// - `array` is `false` if empty, `true` otherwise
    public var boolValue: Bool {
        switch self {
        case .null:
            return false
        case .bool(let b):
            return b
        case .int(let i):
            return i != 0
        case .double(let d):
            return d != 0 && !d.isNaN
        case .string(let s):
            return !s.isEmpty
        case .array(let a):
            return !a.isEmpty
        }
    }

    /// Returns the string representation of this value.
    ///
    /// - Returns: A string describing this value.
    public var stringValue: String {
        switch self {
        case .null:
            return "null"
        case .bool(let b):
            return b ? "true" : "false"
        case .int(let i):
            return String(i)
        case .double(let d):
            return String(d)
        case .string(let s):
            return s
        case .array(let a):
            return "[" + a.map { $0.stringValue }.joined(separator: ", ") + "]"
        }
    }

    /// Attempts to convert this value to an Int64.
    ///
    /// - Returns: The integer value if convertible, `nil` otherwise.
    public var intValue: Int64? {
        switch self {
        case .null:
            return nil
        case .bool(let b):
            return b ? 1 : 0
        case .int(let i):
            return i
        case .double(let d):
            guard d.isFinite else { return nil }
            return Int64(d)
        case .string(let s):
            return Int64(s)
        case .array:
            return nil
        }
    }

    /// Attempts to convert this value to a Double.
    ///
    /// - Returns: The double value if convertible, `nil` otherwise.
    public var doubleValue: Double? {
        switch self {
        case .null:
            return nil
        case .bool(let b):
            return b ? 1.0 : 0.0
        case .int(let i):
            return Double(i)
        case .double(let d):
            return d
        case .string(let s):
            return Double(s)
        case .array:
            return nil
        }
    }

    /// Returns the array contents if this is an array value.
    ///
    /// - Returns: The array elements if this is an array, `nil` otherwise.
    public var arrayValue: [PropertyValue]? {
        if case .array(let a) = self {
            return a
        }
        return nil
    }
}

// MARK: - Equatable Conformance (for array Hashable)

extension PropertyValue {
    public static func == (lhs: PropertyValue, rhs: PropertyValue) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case (.bool(let a), .bool(let b)):
            return a == b
        case (.int(let a), .int(let b)):
            return a == b
        case (.double(let a), .double(let b)):
            // Handle NaN comparison
            if a.isNaN && b.isNaN { return true }
            return a == b
        case (.string(let a), .string(let b)):
            return a == b
        case (.array(let a), .array(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - ExpressibleBy Literals

extension PropertyValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension PropertyValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension PropertyValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .int(value)
    }
}

extension PropertyValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension PropertyValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension PropertyValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: PropertyValue...) {
        self = .array(elements)
    }
}

// MARK: - CustomStringConvertible

extension PropertyValue: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}

// MARK: - Codable

extension PropertyValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    private enum ValueType: String, Codable {
        case null, bool, int, double, string, array
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)

        switch type {
        case .null:
            self = .null
        case .bool:
            let value = try container.decode(Bool.self, forKey: .value)
            self = .bool(value)
        case .int:
            let value = try container.decode(Int64.self, forKey: .value)
            self = .int(value)
        case .double:
            let value = try container.decode(Double.self, forKey: .value)
            self = .double(value)
        case .string:
            let value = try container.decode(String.self, forKey: .value)
            self = .string(value)
        case .array:
            let value = try container.decode([PropertyValue].self, forKey: .value)
            self = .array(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .null:
            try container.encode(ValueType.null, forKey: .type)
        case .bool(let value):
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode(ValueType.int, forKey: .type)
            try container.encode(value, forKey: .value)
        case .double(let value):
            try container.encode(ValueType.double, forKey: .type)
            try container.encode(value, forKey: .value)
        case .string(let value):
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(value, forKey: .value)
        case .array(let value):
            try container.encode(ValueType.array, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}
