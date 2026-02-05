import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ValidationRule Tests")
struct ValidationRuleTests {

    // MARK: - Test Helpers

    /// Creates a sample rule for testing.
    private static func sampleRule(
        specification: Specification = .iso142892,
        clause: String = "8.2.5.26",
        testNumber: Int = 1,
        object: String = "PDDocument",
        description: String = "The document shall contain a StructTreeRoot entry.",
        test: String = "containsStructTreeRoot == true",
        message: String = "Document does not contain StructTreeRoot",
        arguments: [ErrorArgument] = [],
        references: [Reference] = [],
        tags: Set<RuleTag> = [.critical, .machine, .structure]
    ) -> ValidationRule {
        ValidationRule(
            id: RuleID(specification: specification, clause: clause, testNumber: testNumber),
            object: object,
            description: description,
            test: test,
            error: ErrorDetails(message: message, arguments: arguments),
            references: references,
            tags: tags
        )
    }

    // MARK: - Initialization

    @Test("ValidationRule stores all fields correctly")
    func initialization() {
        let refs = [Reference(specification: "ISO 14289-2:2024", clause: "8.2.5.26")]
        let rule = ValidationRuleTests.sampleRule(
            references: refs,
            tags: [.critical, .machine, .structure]
        )

        #expect(rule.id.specification == .iso142892)
        #expect(rule.id.clause == "8.2.5.26")
        #expect(rule.id.testNumber == 1)
        #expect(rule.object == "PDDocument")
        #expect(rule.description == "The document shall contain a StructTreeRoot entry.")
        #expect(rule.test == "containsStructTreeRoot == true")
        #expect(rule.error.message == "Document does not contain StructTreeRoot")
        #expect(rule.references.count == 1)
        #expect(rule.references[0].clause == "8.2.5.26")
        #expect(rule.tags.contains(.critical))
        #expect(rule.tags.contains(.machine))
        #expect(rule.tags.contains(.structure))
    }

    @Test("ValidationRule with default empty references and tags")
    func defaultEmptyCollections() {
        let rule = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "A rule",
            test: "true",
            error: ErrorDetails(message: "Error")
        )

        #expect(rule.references.isEmpty)
        #expect(rule.tags.isEmpty)
    }

    // MARK: - Identifiable

    @Test("ValidationRule id property returns the RuleID")
    func identifiable() {
        let expectedID = RuleID(specification: .iso142892, clause: "8.2.5.26", testNumber: 1)
        let rule = ValidationRuleTests.sampleRule()

        #expect(rule.id == expectedID)
    }

    @Test("Different rules have different ids")
    func differentIds() {
        let rule1 = ValidationRuleTests.sampleRule(clause: "8.2", testNumber: 1)
        let rule2 = ValidationRuleTests.sampleRule(clause: "8.3", testNumber: 1)
        let rule3 = ValidationRuleTests.sampleRule(clause: "8.2", testNumber: 2)

        #expect(rule1.id != rule2.id)
        #expect(rule1.id != rule3.id)
        #expect(rule2.id != rule3.id)
    }

    // MARK: - Unique ID

    @Test("uniqueID produces correct format")
    func uniqueIDFormat() {
        let rule = ValidationRuleTests.sampleRule()
        #expect(rule.uniqueID == "ISO_14289_2-8.2.5.26-1")
    }

    @Test("uniqueID matches RuleID uniqueID")
    func uniqueIDMatchesRuleID() {
        let rule = ValidationRuleTests.sampleRule()
        #expect(rule.uniqueID == rule.id.uniqueID)
    }

    @Test("uniqueID with different specifications")
    func uniqueIDDifferentSpecs() {
        let pdfA = ValidationRuleTests.sampleRule(specification: .iso190051, clause: "6.1", testNumber: 1)
        let pdfUA = ValidationRuleTests.sampleRule(specification: .iso142892, clause: "6.1", testNumber: 1)

        #expect(pdfA.uniqueID == "ISO_19005_1-6.1-1")
        #expect(pdfUA.uniqueID == "ISO_14289_2-6.1-1")
    }

    // MARK: - Tags

    @Test("ValidationRule with multiple tag categories")
    func multipleTags() {
        let rule = ValidationRuleTests.sampleRule(
            tags: [.critical, .machine, .structure, .altText]
        )

        #expect(rule.tags.count == 4)
        #expect(rule.tags.contains(.critical))
        #expect(rule.tags.contains(.machine))
        #expect(rule.tags.contains(.structure))
        #expect(rule.tags.contains(.altText))
    }

    @Test("ValidationRule with empty tags")
    func emptyTags() {
        let rule = ValidationRuleTests.sampleRule(tags: [])
        #expect(rule.tags.isEmpty)
    }

    @Test("ValidationRule tags are a Set (no duplicates)")
    func tagsAreSet() {
        let rule = ValidationRuleTests.sampleRule(
            tags: [.critical, .critical, .machine, .machine]
        )

        #expect(rule.tags.count == 2)
    }

    // MARK: - Object Type Matching

    @Test("ValidationRule object matches PDFObjectType raw values")
    func objectTypeMatching() {
        let docRule = ValidationRuleTests.sampleRule(object: "PDDocument")
        let pageRule = ValidationRuleTests.sampleRule(object: "PDPage")
        let structRule = ValidationRuleTests.sampleRule(object: "PDStructElem")

        #expect(docRule.object == PDFObjectType.pdDocument.rawValue)
        #expect(pageRule.object == PDFObjectType.pdPage.rawValue)
        #expect(structRule.object == PDFObjectType.pdStructElem.rawValue)
    }

    // MARK: - Error Details Integration

    @Test("ValidationRule error details with arguments")
    func errorDetailsWithArguments() {
        let rule = ValidationRuleTests.sampleRule(
            message: "Font %1 is not embedded",
            arguments: [ErrorArgument(name: "fontName")]
        )

        let formatted = rule.error.formattedMessage(with: ["fontName": "Arial"])
        #expect(formatted == "Font Arial is not embedded")
    }

    // MARK: - Codable

    @Test("ValidationRule round-trips through JSON")
    func codableRoundTrip() throws {
        let original = ValidationRuleTests.sampleRule(
            references: [Reference(specification: "ISO 14289-2:2024", clause: "8.2.5.26")],
            tags: [.critical, .machine]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ValidationRule.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.object == original.object)
        #expect(decoded.description == original.description)
        #expect(decoded.test == original.test)
        #expect(decoded.error == original.error)
        #expect(decoded.references.count == original.references.count)
        #expect(decoded.tags == original.tags)
    }

    @Test("ValidationRule with empty optional collections round-trips through JSON")
    func codableRoundTripEmptyCollections() throws {
        let original = ValidationRule(
            id: RuleID(specification: .iso142892, clause: "8.2", testNumber: 1),
            object: "PDDocument",
            description: "Test rule",
            test: "true",
            error: ErrorDetails(message: "Error")
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ValidationRule.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.references.isEmpty)
        #expect(decoded.tags.isEmpty)
    }

    @Test("ValidationRule array round-trips through JSON")
    func codableArrayRoundTrip() throws {
        let rules = [
            ValidationRuleTests.sampleRule(clause: "8.2", testNumber: 1, tags: [.critical]),
            ValidationRuleTests.sampleRule(clause: "8.3", testNumber: 1, tags: [.major, .machine]),
            ValidationRuleTests.sampleRule(clause: "8.4", testNumber: 2, tags: [.minor]),
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(rules)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([ValidationRule].self, from: data)

        #expect(decoded.count == 3)
        #expect(decoded[0].id == rules[0].id)
        #expect(decoded[1].id == rules[1].id)
        #expect(decoded[2].id == rules[2].id)
    }
}
