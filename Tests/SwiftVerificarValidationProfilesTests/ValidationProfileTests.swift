import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ValidationProfile Tests")
struct ValidationProfileTests {

    // MARK: - Test Helpers

    private static let referenceDate = Date(timeIntervalSince1970: 1705276800) // 2024-01-15T00:00:00Z

    private static func sampleDetails(
        name: String = "PDF/UA-2 validation profile"
    ) -> ProfileDetails {
        ProfileDetails(
            name: name,
            description: "Rules for PDF/UA-2",
            creator: "veraPDF Consortium",
            created: referenceDate
        )
    }

    private static func sampleRule(
        clause: String = "8.2",
        testNumber: Int = 1,
        object: String = "PDDocument",
        test: String = "containsStructTreeRoot == true",
        tags: Set<RuleTag> = [.critical, .machine]
    ) -> ValidationRule {
        ValidationRule(
            id: RuleID(specification: .iso142892, clause: clause, testNumber: testNumber),
            object: object,
            description: "Test rule for \(clause)",
            test: test,
            error: ErrorDetails(message: "Rule \(clause) failed"),
            tags: tags
        )
    }

    private static func sampleProfile(
        rules: [ValidationRule]? = nil,
        variables: [ProfileVariable] = [],
        flavour: PDFFlavour = .pdfUA2,
        hash: String? = nil
    ) -> ValidationProfile {
        let defaultRules = [
            sampleRule(clause: "8.2", object: "PDDocument", tags: [.critical, .machine, .structure]),
            sampleRule(clause: "8.3", object: "PDPage", tags: [.major, .machine]),
            sampleRule(clause: "8.4", object: "PDStructElem", tags: [.critical, .machine, .altText]),
            sampleRule(clause: "8.5", object: "PDDocument", tags: [.minor, .human]),
        ]

        return ValidationProfile(
            details: sampleDetails(),
            hash: hash,
            rules: rules ?? defaultRules,
            variables: variables,
            flavour: flavour
        )
    }

    // MARK: - Initialization

    @Test("ValidationProfile stores all fields correctly")
    func initialization() {
        let variables = [ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Max difference")]
        let profile = ValidationProfileTests.sampleProfile(
            variables: variables,
            flavour: .pdfUA2,
            hash: "abc123"
        )

        #expect(profile.details.name == "PDF/UA-2 validation profile")
        #expect(profile.hash == "abc123")
        #expect(profile.rules.count == 4)
        #expect(profile.variables.count == 1)
        #expect(profile.variables[0].name == "maxDiff")
        #expect(profile.flavour == .pdfUA2)
    }

    @Test("ValidationProfile with nil hash")
    func nilHash() {
        let profile = ValidationProfileTests.sampleProfile(hash: nil)
        #expect(profile.hash == nil)
    }

    @Test("ValidationProfile with default empty variables")
    func defaultEmptyVariables() {
        let profile = ValidationProfile(
            details: ValidationProfileTests.sampleDetails(),
            rules: [],
            flavour: .pdfUA2
        )
        #expect(profile.variables.isEmpty)
    }

    @Test("ValidationProfile with default nil hash")
    func defaultNilHash() {
        let profile = ValidationProfile(
            details: ValidationProfileTests.sampleDetails(),
            rules: [],
            flavour: .pdfUA2
        )
        #expect(profile.hash == nil)
    }

    @Test("ValidationProfile with different flavours")
    func differentFlavours() {
        let pdfUA2 = ValidationProfileTests.sampleProfile(flavour: .pdfUA2)
        let pdfA1b = ValidationProfileTests.sampleProfile(flavour: .pdfA1b)
        let wcag = ValidationProfileTests.sampleProfile(flavour: .wcag22)

        #expect(pdfUA2.flavour == .pdfUA2)
        #expect(pdfA1b.flavour == .pdfA1b)
        #expect(wcag.flavour == .wcag22)
    }

    // MARK: - Rule Count

    @Test("ruleCount returns correct count")
    func ruleCount() {
        let profile = ValidationProfileTests.sampleProfile()
        #expect(profile.ruleCount == 4)
    }

    @Test("ruleCount returns zero for empty profile")
    func ruleCountEmpty() {
        let profile = ValidationProfileTests.sampleProfile(rules: [])
        #expect(profile.ruleCount == 0)
    }

    // MARK: - Rules By Object Type

    @Test("rules(for:) filters by object type")
    func rulesByObjectType() {
        let profile = ValidationProfileTests.sampleProfile()

        let docRules = profile.rules(for: .pdDocument)
        let pageRules = profile.rules(for: .pdPage)
        let structRules = profile.rules(for: .pdStructElem)
        let fontRules = profile.rules(for: .pdFont)

        #expect(docRules.count == 2)
        #expect(pageRules.count == 1)
        #expect(structRules.count == 1)
        #expect(fontRules.count == 0)
    }

    @Test("rules(for:) returns empty array for non-matching type")
    func rulesByObjectTypeNoMatch() {
        let profile = ValidationProfileTests.sampleProfile()

        let result = profile.rules(for: .cosStream)
        #expect(result.isEmpty)
    }

    // MARK: - Rules By Tags (All Tags)

    @Test("rules(withAllTags:) returns rules matching all specified tags")
    func rulesWithAllTags() {
        let profile = ValidationProfileTests.sampleProfile()

        let criticalMachine = profile.rules(withAllTags: [.critical, .machine])
        #expect(criticalMachine.count == 2)

        let criticalMachineStructure = profile.rules(withAllTags: [.critical, .machine, .structure])
        #expect(criticalMachineStructure.count == 1)
        #expect(criticalMachineStructure[0].id.clause == "8.2")
    }

    @Test("rules(withAllTags:) returns empty for unmatched tag combination")
    func rulesWithAllTagsNoMatch() {
        let profile = ValidationProfileTests.sampleProfile()

        let result = profile.rules(withAllTags: [.critical, .human, .font])
        #expect(result.isEmpty)
    }

    @Test("rules(withAllTags:) with empty tag set returns all rules")
    func rulesWithAllTagsEmpty() {
        let profile = ValidationProfileTests.sampleProfile()

        let result = profile.rules(withAllTags: [])
        #expect(result.count == 4)
    }

    // MARK: - Rules By Tags (Any Tag)

    @Test("rules(withAnyTag:) returns rules matching at least one tag")
    func rulesWithAnyTag() {
        let profile = ValidationProfileTests.sampleProfile()

        let criticalOrMajor = profile.rules(withAnyTag: [.critical, .major])
        #expect(criticalOrMajor.count == 3)

        let humanRules = profile.rules(withAnyTag: [.human])
        #expect(humanRules.count == 1)
        #expect(humanRules[0].id.clause == "8.5")
    }

    @Test("rules(withAnyTag:) returns empty for unmatched tags")
    func rulesWithAnyTagNoMatch() {
        let profile = ValidationProfileTests.sampleProfile()

        let result = profile.rules(withAnyTag: [.font, .table])
        #expect(result.isEmpty)
    }

    @Test("rules(withAnyTag:) with empty tag set returns empty")
    func rulesWithAnyTagEmpty() {
        let profile = ValidationProfileTests.sampleProfile()

        let result = profile.rules(withAnyTag: [])
        #expect(result.isEmpty)
    }

    @Test("rules(withAnyTag:) with altText tag")
    func rulesWithAnyTagAltText() {
        let profile = ValidationProfileTests.sampleProfile()

        let result = profile.rules(withAnyTag: [.altText])
        #expect(result.count == 1)
        #expect(result[0].id.clause == "8.4")
    }

    // MARK: - Codable

    @Test("ValidationProfile round-trips through JSON")
    func codableRoundTrip() throws {
        let variables = [ProfileVariable(name: "maxDiff", defaultValue: "1", description: "Max difference")]
        let original = ValidationProfileTests.sampleProfile(
            variables: variables,
            flavour: .pdfUA2,
            hash: "abc123"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ValidationProfile.self, from: data)

        #expect(decoded.details.name == original.details.name)
        #expect(decoded.hash == original.hash)
        #expect(decoded.rules.count == original.rules.count)
        #expect(decoded.variables.count == original.variables.count)
        #expect(decoded.flavour == original.flavour)
    }

    @Test("ValidationProfile with empty rules and variables round-trips")
    func codableRoundTripEmpty() throws {
        let original = ValidationProfile(
            details: ValidationProfileTests.sampleDetails(),
            hash: nil,
            rules: [],
            variables: [],
            flavour: .pdfA1b
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(ValidationProfile.self, from: data)

        #expect(decoded.details.name == "PDF/UA-2 validation profile")
        #expect(decoded.hash == nil)
        #expect(decoded.rules.isEmpty)
        #expect(decoded.variables.isEmpty)
        #expect(decoded.flavour == .pdfA1b)
    }

    @Test("ValidationProfile with multiple rules preserves order")
    func codableRoundTripPreservesOrder() throws {
        let rules = [
            ValidationProfileTests.sampleRule(clause: "1.0", testNumber: 1),
            ValidationProfileTests.sampleRule(clause: "2.0", testNumber: 1),
            ValidationProfileTests.sampleRule(clause: "3.0", testNumber: 1),
        ]
        let original = ValidationProfileTests.sampleProfile(rules: rules)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(ValidationProfile.self, from: data)

        #expect(decoded.rules.count == 3)
        #expect(decoded.rules[0].id.clause == "1.0")
        #expect(decoded.rules[1].id.clause == "2.0")
        #expect(decoded.rules[2].id.clause == "3.0")
    }
}
