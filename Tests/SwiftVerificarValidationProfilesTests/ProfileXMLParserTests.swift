import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileXMLParser Tests")
struct ProfileXMLParserTests {

    // MARK: - Test Fixtures

    let minimalProfileXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
            <details creator="Test" created="2024-01-15T00:00:00.000Z">
                <name>Test Profile</name>
                <description>A test profile</description>
            </details>
            <rules/>
        </profile>
        """

    let profileWithRulesXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
            <details creator="veraPDF" created="2024-01-15T00:00:00.000Z">
                <name>PDF/UA-2 validation profile</name>
                <description>Validation rules for PDF/UA-2</description>
            </details>
            <hash>abc123</hash>
            <rules>
                <rule object="PDDocument" tags="structure,machine">
                    <id specification="ISO_14289_2" clause="8.2.1" testNumber="1"/>
                    <description>Document must have StructTreeRoot</description>
                    <test>containsStructTreeRoot == true</test>
                    <error>
                        <message>StructTreeRoot entry is not present</message>
                        <arguments/>
                    </error>
                    <references>
                        <reference specification="ISO 32000-2:2020" clause="14.7"/>
                    </references>
                </rule>
                <rule object="PDStructElem" tags="structure">
                    <id specification="ISO_14289_2" clause="8.2.1" testNumber="2"/>
                    <description>Structure element must have parent</description>
                    <test>containsParent == true</test>
                    <error>
                        <message>Missing parent entry in %1</message>
                        <arguments>
                            <argument>elementType</argument>
                        </arguments>
                    </error>
                    <references/>
                </rule>
            </rules>
            <variables/>
        </profile>
        """

    let profileWithVariablesXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFA_1_A">
            <details creator="Test" created="2024-01-01T00:00:00Z">
                <name>Test with Variables</name>
                <description>Profile with variables</description>
            </details>
            <rules/>
            <variables>
                <variable name="maxWidth" object="PDFont">
                    <defaultValue>1</defaultValue>
                </variable>
            </variables>
        </profile>
        """

    // MARK: - Basic Parsing

    @Test("Parser can be created")
    func parserCreation() {
        let parser = ProfileXMLParser()
        #expect(parser != nil)
    }

    @Test("Parse minimal profile from data")
    func parseMinimalProfile() throws {
        let parser = ProfileXMLParser()
        let data = minimalProfileXML.data(using: .utf8)!

        let profile = try parser.parse(data: data)

        #expect(profile.flavour == .pdfUA2)
        #expect(profile.details.name == "Test Profile")
        #expect(profile.details.description == "A test profile")
        #expect(profile.details.creator == "Test")
        #expect(profile.rules.isEmpty)
    }

    @Test("Parse profile from string")
    func parseFromString() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: minimalProfileXML)

        #expect(profile.flavour == .pdfUA2)
        #expect(profile.details.name == "Test Profile")
    }

    // MARK: - Profile Details

    @Test("Parse profile details correctly")
    func parseProfileDetails() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.details.name == "PDF/UA-2 validation profile")
        #expect(profile.details.description == "Validation rules for PDF/UA-2")
        #expect(profile.details.creator == "veraPDF")
    }

    @Test("Parse profile hash")
    func parseProfileHash() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.hash == "abc123")
    }

    @Test("Empty hash becomes nil")
    func emptyHashBecomesNil() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <hash></hash>
                <rules/>
            </profile>
            """
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: xml)

        #expect(profile.hash == nil)
    }

    // MARK: - Rules Parsing

    @Test("Parse rules count")
    func parseRulesCount() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules.count == 2)
    }

    @Test("Parse rule object type")
    func parseRuleObjectType() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].object == "PDDocument")
        #expect(profile.rules[1].object == "PDStructElem")
    }

    @Test("Parse rule ID")
    func parseRuleID() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        let firstRule = profile.rules[0]
        #expect(firstRule.id.specification == .iso142892)
        #expect(firstRule.id.clause == "8.2.1")
        #expect(firstRule.id.testNumber == 1)
    }

    @Test("Parse rule description")
    func parseRuleDescription() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].description == "Document must have StructTreeRoot")
    }

    @Test("Parse rule test expression")
    func parseRuleTest() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].test == "containsStructTreeRoot == true")
        #expect(profile.rules[1].test == "containsParent == true")
    }

    @Test("Parse rule tags")
    func parseRuleTags() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].tags.contains(.structure))
        #expect(profile.rules[0].tags.contains(.machine))
        #expect(profile.rules[1].tags.contains(.structure))
    }

    @Test("Parse rule error message")
    func parseRuleErrorMessage() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].error.message == "StructTreeRoot entry is not present")
    }

    @Test("Parse rule error arguments")
    func parseRuleErrorArguments() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].error.arguments.isEmpty)
        #expect(profile.rules[1].error.arguments.count == 1)
        #expect(profile.rules[1].error.arguments[0].name == "elementType")
    }

    @Test("Parse rule references")
    func parseRuleReferences() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithRulesXML)

        #expect(profile.rules[0].references.count == 1)
        #expect(profile.rules[0].references[0].specification == "ISO 32000-2:2020")
        #expect(profile.rules[0].references[0].clause == "14.7")
        #expect(profile.rules[1].references.isEmpty)
    }

    // MARK: - Variables Parsing

    @Test("Parse profile variables")
    func parseVariables() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: profileWithVariablesXML)

        #expect(profile.variables.count == 1)
        #expect(profile.variables[0].name == "maxWidth")
        #expect(profile.variables[0].defaultValue == "1")
    }

    // MARK: - Flavour Parsing

    @Test("Parse PDF/UA-2 flavour")
    func parsePDFUA2Flavour() throws {
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: minimalProfileXML)

        #expect(profile.flavour == .pdfUA2)
    }

    @Test("Parse PDF/A-1a flavour")
    func parsePDFA1aFlavour() throws {
        let xml = minimalProfileXML.replacingOccurrences(of: "PDFUA_2", with: "PDFA_1_A")
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: xml)

        #expect(profile.flavour == .pdfA1a)
    }

    // MARK: - Error Handling

    @Test("Throws emptyProfile for empty data")
    func emptyDataThrows() {
        let parser = ProfileXMLParser()

        #expect(throws: ProfileParseError.self) {
            try parser.parse(data: Data())
        }
    }

    @Test("Throws emptyProfile for empty string")
    func emptyStringThrows() {
        let parser = ProfileXMLParser()

        #expect(throws: ProfileParseError.self) {
            try parser.parse(xmlString: "")
        }
    }

    @Test("Throws for invalid XML")
    func invalidXMLThrows() {
        let parser = ProfileXMLParser()
        let invalidXML = "<not valid xml"

        #expect(throws: ProfileParseError.self) {
            try parser.parse(xmlString: invalidXML)
        }
    }

    @Test("Throws for missing flavour attribute")
    func missingFlavourThrows() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules/>
            </profile>
            """
        let parser = ProfileXMLParser()

        #expect(throws: ProfileParseError.self) {
            try parser.parse(xmlString: xml)
        }
    }

    // MARK: - Date Parsing

    @Test("Parse ISO 8601 date with fractional seconds")
    func parseDateWithFractionalSeconds() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-15T10:30:45.123Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules/>
            </profile>
            """
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: xml)

        // Just verify it parses without error - exact date verification would require calendar math
        #expect(profile.details.created != Date.distantPast)
    }

    @Test("Parse ISO 8601 date without fractional seconds")
    func parseDateWithoutFractionalSeconds() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-15T10:30:45Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules/>
            </profile>
            """
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: xml)

        #expect(profile.details.created != Date.distantPast)
    }

    // MARK: - Thread Safety

    @Test("Parser is value type")
    func parserIsValueType() {
        var parser1 = ProfileXMLParser()
        let parser2 = parser1
        // Both should work independently since it's a struct
        _ = parser1
        _ = parser2
    }

    // MARK: - Complex Profiles

    @Test("Parse profile with multiple rules and references")
    func parseComplexProfile() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Complex" created="2024-06-01T00:00:00Z">
                    <name>Complex Profile</name>
                    <description>A complex profile with multiple elements</description>
                </details>
                <hash>hash123</hash>
                <rules>
                    <rule object="PDDocument" tags="metadata,machine,critical">
                        <id specification="ISO_14289_2" clause="5" testNumber="1"/>
                        <description>Rule 1</description>
                        <test>test1 == true</test>
                        <error>
                            <message>Error 1 with %1 and %2</message>
                            <arguments>
                                <argument>arg1</argument>
                                <argument>arg2</argument>
                            </arguments>
                        </error>
                        <references>
                            <reference specification="Spec A" clause="1.1"/>
                            <reference specification="Spec B" clause="2.2"/>
                        </references>
                    </rule>
                    <rule object="PDPage" tags="structure">
                        <id specification="ISO_14289_2" clause="6" testNumber="2"/>
                        <description>Rule 2</description>
                        <test>test2 != null</test>
                        <error>
                            <message>Error 2</message>
                            <arguments/>
                        </error>
                        <references/>
                    </rule>
                </rules>
                <variables>
                    <variable name="var1" object="PDFont">
                        <defaultValue>value1</defaultValue>
                    </variable>
                </variables>
            </profile>
            """
        let parser = ProfileXMLParser()
        let profile = try parser.parse(xmlString: xml)

        // Verify profile structure
        #expect(profile.flavour == .pdfUA2)
        #expect(profile.hash == "hash123")
        #expect(profile.rules.count == 2)
        #expect(profile.variables.count == 1)

        // Verify first rule
        let rule1 = profile.rules[0]
        #expect(rule1.tags.count == 3)
        #expect(rule1.error.arguments.count == 2)
        #expect(rule1.references.count == 2)

        // Verify second rule
        let rule2 = profile.rules[1]
        #expect(rule2.object == "PDPage")
        #expect(rule2.id.testNumber == 2)
    }
}
