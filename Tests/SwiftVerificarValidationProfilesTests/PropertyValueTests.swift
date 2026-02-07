import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("PropertyValue Tests")
struct PropertyValueTests {

    // MARK: - Truthiness Tests

    @Test("null is falsy")
    func nullIsFalsy() {
        let value = PropertyValue.null
        #expect(value.boolValue == false)
    }

    @Test("bool true is truthy")
    func boolTrueIsTruthy() {
        let value = PropertyValue.bool(true)
        #expect(value.boolValue == true)
    }

    @Test("bool false is falsy")
    func boolFalseIsFalsy() {
        let value = PropertyValue.bool(false)
        #expect(value.boolValue == false)
    }

    @Test("int zero is falsy")
    func intZeroIsFalsy() {
        let value = PropertyValue.int(0)
        #expect(value.boolValue == false)
    }

    @Test("non-zero int is truthy")
    func nonZeroIntIsTruthy() {
        #expect(PropertyValue.int(1).boolValue == true)
        #expect(PropertyValue.int(-1).boolValue == true)
        #expect(PropertyValue.int(42).boolValue == true)
    }

    @Test("double zero is falsy")
    func doubleZeroIsFalsy() {
        let value = PropertyValue.double(0.0)
        #expect(value.boolValue == false)
    }

    @Test("non-zero double is truthy")
    func nonZeroDoubleIsTruthy() {
        #expect(PropertyValue.double(1.0).boolValue == true)
        #expect(PropertyValue.double(-0.5).boolValue == true)
        #expect(PropertyValue.double(3.14).boolValue == true)
    }

    @Test("NaN is falsy")
    func nanIsFalsy() {
        let value = PropertyValue.double(Double.nan)
        #expect(value.boolValue == false)
    }

    @Test("empty string is falsy")
    func emptyStringIsFalsy() {
        let value = PropertyValue.string("")
        #expect(value.boolValue == false)
    }

    @Test("non-empty string is truthy")
    func nonEmptyStringIsTruthy() {
        #expect(PropertyValue.string("hello").boolValue == true)
        #expect(PropertyValue.string(" ").boolValue == true)
        #expect(PropertyValue.string("0").boolValue == true)
    }

    @Test("empty array is falsy")
    func emptyArrayIsFalsy() {
        let value = PropertyValue.array([])
        #expect(value.boolValue == false)
    }

    @Test("non-empty array is truthy")
    func nonEmptyArrayIsTruthy() {
        let value = PropertyValue.array([.null])
        #expect(value.boolValue == true)
    }

    // MARK: - String Value Tests

    @Test("null stringValue is 'null'")
    func nullStringValue() {
        #expect(PropertyValue.null.stringValue == "null")
    }

    @Test("bool stringValue")
    func boolStringValue() {
        #expect(PropertyValue.bool(true).stringValue == "true")
        #expect(PropertyValue.bool(false).stringValue == "false")
    }

    @Test("int stringValue")
    func intStringValue() {
        #expect(PropertyValue.int(42).stringValue == "42")
        #expect(PropertyValue.int(-5).stringValue == "-5")
    }

    @Test("double stringValue")
    func doubleStringValue() {
        #expect(PropertyValue.double(3.14).stringValue == "3.14")
    }

    @Test("string stringValue")
    func stringStringValue() {
        #expect(PropertyValue.string("hello").stringValue == "hello")
    }

    @Test("array stringValue")
    func arrayStringValue() {
        let arr = PropertyValue.array([.int(1), .int(2), .int(3)])
        #expect(arr.stringValue == "[1, 2, 3]")
    }

    // MARK: - Int Value Tests

    @Test("null intValue is nil")
    func nullIntValue() {
        #expect(PropertyValue.null.intValue == nil)
    }

    @Test("bool intValue")
    func boolIntValue() {
        #expect(PropertyValue.bool(true).intValue == 1)
        #expect(PropertyValue.bool(false).intValue == 0)
    }

    @Test("int intValue")
    func intIntValue() {
        #expect(PropertyValue.int(42).intValue == 42)
    }

    @Test("double intValue truncates")
    func doubleIntValue() {
        #expect(PropertyValue.double(3.7).intValue == 3)
        #expect(PropertyValue.double(-2.9).intValue == -2)
    }

    @Test("infinite double intValue is nil")
    func infiniteDoubleIntValue() {
        #expect(PropertyValue.double(.infinity).intValue == nil)
    }

    @Test("string intValue parses")
    func stringIntValue() {
        #expect(PropertyValue.string("42").intValue == 42)
        #expect(PropertyValue.string("invalid").intValue == nil)
    }

    @Test("array intValue is nil")
    func arrayIntValue() {
        #expect(PropertyValue.array([]).intValue == nil)
    }

    // MARK: - Double Value Tests

    @Test("null doubleValue is nil")
    func nullDoubleValue() {
        #expect(PropertyValue.null.doubleValue == nil)
    }

    @Test("bool doubleValue")
    func boolDoubleValue() {
        #expect(PropertyValue.bool(true).doubleValue == 1.0)
        #expect(PropertyValue.bool(false).doubleValue == 0.0)
    }

    @Test("int doubleValue")
    func intDoubleValue() {
        #expect(PropertyValue.int(42).doubleValue == 42.0)
    }

    @Test("double doubleValue")
    func doubleDoubleValue() {
        #expect(PropertyValue.double(3.14).doubleValue == 3.14)
    }

    @Test("string doubleValue parses")
    func stringDoubleValue() {
        #expect(PropertyValue.string("3.14").doubleValue == 3.14)
        #expect(PropertyValue.string("invalid").doubleValue == nil)
    }

    @Test("array doubleValue is nil")
    func arrayDoubleValue() {
        #expect(PropertyValue.array([]).doubleValue == nil)
    }

    // MARK: - Array Value Tests

    @Test("non-array arrayValue is nil")
    func nonArrayArrayValue() {
        #expect(PropertyValue.null.arrayValue == nil)
        #expect(PropertyValue.int(1).arrayValue == nil)
        #expect(PropertyValue.string("test").arrayValue == nil)
    }

    @Test("array arrayValue returns contents")
    func arrayArrayValue() {
        let arr = PropertyValue.array([.int(1), .int(2)])
        #expect(arr.arrayValue?.count == 2)
    }

    // MARK: - Equality Tests

    @Test("null equals null")
    func nullEqualsNull() {
        #expect(PropertyValue.null == PropertyValue.null)
    }

    @Test("bool equality")
    func boolEquality() {
        #expect(PropertyValue.bool(true) == PropertyValue.bool(true))
        #expect(PropertyValue.bool(false) == PropertyValue.bool(false))
        #expect(PropertyValue.bool(true) != PropertyValue.bool(false))
    }

    @Test("int equality")
    func intEquality() {
        #expect(PropertyValue.int(5) == PropertyValue.int(5))
        #expect(PropertyValue.int(5) != PropertyValue.int(6))
    }

    @Test("double equality")
    func doubleEquality() {
        #expect(PropertyValue.double(3.14) == PropertyValue.double(3.14))
        #expect(PropertyValue.double(3.14) != PropertyValue.double(3.15))
    }

    @Test("NaN equals NaN for PropertyValue")
    func nanEquality() {
        let nan1 = PropertyValue.double(.nan)
        let nan2 = PropertyValue.double(.nan)
        #expect(nan1 == nan2)
    }

    @Test("string equality")
    func stringEquality() {
        #expect(PropertyValue.string("hello") == PropertyValue.string("hello"))
        #expect(PropertyValue.string("hello") != PropertyValue.string("world"))
    }

    @Test("array equality")
    func arrayEquality() {
        let arr1 = PropertyValue.array([.int(1), .int(2)])
        let arr2 = PropertyValue.array([.int(1), .int(2)])
        let arr3 = PropertyValue.array([.int(1), .int(3)])
        #expect(arr1 == arr2)
        #expect(arr1 != arr3)
    }

    @Test("different types are not equal")
    func differentTypesNotEqual() {
        #expect(PropertyValue.null != PropertyValue.bool(false))
        #expect(PropertyValue.int(0) != PropertyValue.double(0.0))
        #expect(PropertyValue.string("1") != PropertyValue.int(1))
    }

    // MARK: - Literal Conformance Tests

    @Test("ExpressibleByNilLiteral")
    func nilLiteral() {
        let value: PropertyValue = nil
        #expect(value == .null)
    }

    @Test("ExpressibleByBooleanLiteral")
    func booleanLiteral() {
        let value: PropertyValue = true
        #expect(value == .bool(true))
    }

    @Test("ExpressibleByIntegerLiteral")
    func integerLiteral() {
        let value: PropertyValue = 42
        #expect(value == .int(42))
    }

    @Test("ExpressibleByFloatLiteral")
    func floatLiteral() {
        let value: PropertyValue = 3.14
        #expect(value == .double(3.14))
    }

    @Test("ExpressibleByStringLiteral")
    func stringLiteral() {
        let value: PropertyValue = "hello"
        #expect(value == .string("hello"))
    }

    @Test("ExpressibleByArrayLiteral")
    func arrayLiteral() {
        let value: PropertyValue = [1, 2, 3]
        #expect(value == .array([.int(1), .int(2), .int(3)]))
    }

    // MARK: - CustomStringConvertible Tests

    @Test("description matches stringValue")
    func descriptionMatchesStringValue() {
        let values: [PropertyValue] = [
            .null,
            .bool(true),
            .int(42),
            .double(3.14),
            .string("test"),
            .array([.int(1)])
        ]
        for value in values {
            #expect(value.description == value.stringValue)
        }
    }

    // MARK: - Codable Tests

    @Test("null round-trips through JSON")
    func nullCodableRoundTrip() throws {
        let original = PropertyValue.null
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("bool round-trips through JSON")
    func boolCodableRoundTrip() throws {
        for value in [true, false] {
            let original = PropertyValue.bool(value)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
            #expect(decoded == original)
        }
    }

    @Test("int round-trips through JSON")
    func intCodableRoundTrip() throws {
        let original = PropertyValue.int(42)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("double round-trips through JSON")
    func doubleCodableRoundTrip() throws {
        let original = PropertyValue.double(3.14)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("string round-trips through JSON")
    func stringCodableRoundTrip() throws {
        let original = PropertyValue.string("hello world")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("array round-trips through JSON")
    func arrayCodableRoundTrip() throws {
        let original = PropertyValue.array([.int(1), .string("two"), .bool(true)])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
        #expect(decoded == original)
    }

    @Test("nested array round-trips through JSON")
    func nestedArrayCodableRoundTrip() throws {
        let original = PropertyValue.array([
            .array([.int(1), .int(2)]),
            .array([.int(3), .int(4)])
        ])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PropertyValue.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Hashable Tests

    @Test("PropertyValue is hashable")
    func hashable() {
        let set: Set<PropertyValue> = [
            .null,
            .bool(true),
            .int(1),
            .double(1.5),
            .string("test"),
            .array([.int(1)])
        ]
        #expect(set.count == 6)
    }
}
