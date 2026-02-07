import Testing
@testable import SwiftVerificarValidationProfiles

@Suite("ValidationContext Tests")
struct ValidationContextTests {

    @Test("Creates context with object type and properties")
    func createBasicContext() {
        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["key": .string("value")]
        )

        #expect(context.objectType == .pdDocument)
        #expect(context.properties.count == 1)
        #expect(context.properties["key"] == .string("value"))
        #expect(context.variables.isEmpty)
    }

    @Test("Creates context with variables")
    func createContextWithVariables() {
        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [:],
            variables: ["maxVersion": .string("2.0")]
        )

        #expect(context.variables.count == 1)
        #expect(context.variables["maxVersion"] == .string("2.0"))
    }

    @Test("Creates empty context")
    func createEmptyContext() {
        let context = ValidationContext(objectType: .pdDocument)

        #expect(context.objectType == .pdDocument)
        #expect(context.properties.isEmpty)
        #expect(context.variables.isEmpty)
    }

    @Test("Merges properties and variables in allProperties")
    func mergesPropertiesAndVariables() {
        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["prop1": .string("value1")],
            variables: ["var1": .string("value2")]
        )

        let all = context.allProperties
        #expect(all.count == 2)
        #expect(all["prop1"] == .string("value1"))
        #expect(all["var1"] == .string("value2"))
    }

    @Test("Properties take precedence over variables in allProperties")
    func propertiesTakePrecedence() {
        let context = ValidationContext(
            objectType: .pdDocument,
            properties: ["key": .string("fromProperties")],
            variables: ["key": .string("fromVariables")]
        )

        let all = context.allProperties
        #expect(all.count == 1)
        #expect(all["key"] == .string("fromProperties"))
    }

    @Test("Adds additional properties")
    func addAdditionalProperties() {
        let original = ValidationContext(
            objectType: .pdDocument,
            properties: ["key1": .string("value1")]
        )

        let updated = original.adding(properties: ["key2": .string("value2")])

        #expect(updated.properties.count == 2)
        #expect(updated.properties["key1"] == .string("value1"))
        #expect(updated.properties["key2"] == .string("value2"))
        #expect(updated.objectType == .pdDocument)
    }

    @Test("Overwrites properties when adding")
    func overwritesPropertiesWhenAdding() {
        let original = ValidationContext(
            objectType: .pdDocument,
            properties: ["key": .string("old")]
        )

        let updated = original.adding(properties: ["key": .string("new")])

        #expect(updated.properties.count == 1)
        #expect(updated.properties["key"] == .string("new"))
    }

    @Test("Adds additional variables")
    func addAdditionalVariables() {
        let original = ValidationContext(
            objectType: .pdDocument,
            variables: ["var1": .string("value1")]
        )

        let updated = original.adding(variables: ["var2": .string("value2")])

        #expect(updated.variables.count == 2)
        #expect(updated.variables["var1"] == .string("value1"))
        #expect(updated.variables["var2"] == .string("value2"))
    }

    @Test("Overwrites variables when adding")
    func overwritesVariablesWhenAdding() {
        let original = ValidationContext(
            objectType: .pdDocument,
            variables: ["key": .string("old")]
        )

        let updated = original.adding(variables: ["key": .string("new")])

        #expect(updated.variables.count == 1)
        #expect(updated.variables["key"] == .string("new"))
    }

    @Test("Adding properties does not modify original context")
    func addingPropertiesDoesNotModifyOriginal() {
        let original = ValidationContext(
            objectType: .pdDocument,
            properties: ["key1": .string("value1")]
        )

        _ = original.adding(properties: ["key2": .string("value2")])

        #expect(original.properties.count == 1)
        #expect(original.properties["key1"] == .string("value1"))
        #expect(original.properties["key2"] == nil)
    }

    @Test("Adding variables does not modify original context")
    func addingVariablesDoesNotModifyOriginal() {
        let original = ValidationContext(
            objectType: .pdDocument,
            variables: ["var1": .string("value1")]
        )

        _ = original.adding(variables: ["var2": .string("value2")])

        #expect(original.variables.count == 1)
        #expect(original.variables["var1"] == .string("value1"))
        #expect(original.variables["var2"] == nil)
    }

    @Test("Context with multiple property types")
    func contextWithMultiplePropertyTypes() {
        let context = ValidationContext(
            objectType: .pdDocument,
            properties: [
                "bool": .bool(true),
                "int": .int(42),
                "double": .double(3.14),
                "string": .string("text"),
                "array": .array([.int(1), .int(2)]),
                "null": .null
            ]
        )

        let all = context.allProperties
        #expect(all.count == 6)
        #expect(all["bool"] == .bool(true))
        #expect(all["int"] == .int(42))
        #expect(all["double"] == .double(3.14))
        #expect(all["string"] == .string("text"))
        #expect(all["array"] == .array([.int(1), .int(2)]))
        #expect(all["null"] == .null)
    }

    @Test("Context with all PDF object types")
    func contextWithAllObjectTypes() {
        // Test a sampling of object types
        let types: [PDFObjectType] = [
            .pdDocument,
            .pdPage,
            .pdStructTreeRoot,
            .pdAnnot,
            .pdFont,
            .seDocument,
            .saStructElem
        ]

        for objectType in types {
            let context = ValidationContext(objectType: objectType)
            #expect(context.objectType == objectType)
        }
    }
}
