import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileXMLDelegate Tests")
struct ProfileXMLDelegateTests {

    // MARK: - Basic Parsing

    @Test("Delegate can be created")
    func delegateCreation() {
        let delegate = ProfileXMLDelegate()
        #expect(delegate.profile == nil)
        #expect(delegate.parseError == nil)
    }

    @Test("Delegate produces profile after successful parse")
    func successfulParse() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-15T00:00:00.000Z">
                    <name>Test</name>
                    <description>Test Desc</description>
                </details>
                <rules/>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        #expect(delegate.profile != nil)
        #expect(delegate.parseError == nil)
    }

    @Test("Delegate stores error on parse failure")
    func parseFailure() {
        let invalidXML = "<not valid xml"

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: invalidXML.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(!parser.parse())
        #expect(delegate.parseError != nil)
    }

    // MARK: - State Reset

    @Test("Delegate resets state on new document")
    func stateReset() {
        let xml1 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_1">
                <details creator="Creator1" created="2024-01-01T00:00:00Z">
                    <name>Profile 1</name>
                    <description>Desc 1</description>
                </details>
                <rules/>
            </profile>
            """

        let xml2 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Creator2" created="2024-06-01T00:00:00Z">
                    <name>Profile 2</name>
                    <description>Desc 2</description>
                </details>
                <rules/>
            </profile>
            """

        let delegate = ProfileXMLDelegate()

        // Parse first document
        let parser1 = XMLParser(data: xml1.data(using: .utf8)!)
        parser1.delegate = delegate
        #expect(parser1.parse())
        #expect(delegate.profile?.flavour == .pdfUA1)
        #expect(delegate.profile?.details.name == "Profile 1")

        // Parse second document - should completely reset
        let parser2 = XMLParser(data: xml2.data(using: .utf8)!)
        parser2.delegate = delegate
        #expect(parser2.parse())
        #expect(delegate.profile?.flavour == .pdfUA2)
        #expect(delegate.profile?.details.name == "Profile 2")
    }

    // MARK: - Tag Parsing

    @Test("Delegate parses comma-separated tags")
    func parseCommaSeparatedTags() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules>
                    <rule object="PDDocument" tags="structure,machine,critical">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>Test rule</description>
                        <test>true</test>
                        <error>
                            <message>Error</message>
                            <arguments/>
                        </error>
                        <references/>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        #expect(delegate.profile?.rules.count == 1)

        let tags = delegate.profile?.rules[0].tags ?? []
        #expect(tags.contains(.structure))
        #expect(tags.contains(.machine))
        #expect(tags.contains(.critical))
    }

    @Test("Delegate handles empty tags attribute")
    func emptyTagsAttribute() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules>
                    <rule object="PDDocument" tags="">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>Test rule</description>
                        <test>true</test>
                        <error>
                            <message>Error</message>
                            <arguments/>
                        </error>
                        <references/>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        #expect(delegate.profile?.rules[0].tags.isEmpty == true)
    }

    @Test("Delegate ignores invalid tags")
    func invalidTagsIgnored() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules>
                    <rule object="PDDocument" tags="structure,invalid_tag,machine">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>Test rule</description>
                        <test>true</test>
                        <error>
                            <message>Error</message>
                            <arguments/>
                        </error>
                        <references/>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        let tags = delegate.profile?.rules[0].tags ?? []
        #expect(tags.count == 2) // Only valid tags
        #expect(tags.contains(.structure))
        #expect(tags.contains(.machine))
    }

    // MARK: - Multiple Rules

    @Test("Delegate accumulates multiple rules")
    func multipleRules() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules>
                    <rule object="PDDocument">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>Rule 1</description>
                        <test>test1</test>
                        <error><message>Error 1</message><arguments/></error>
                        <references/>
                    </rule>
                    <rule object="PDPage">
                        <id specification="ISO_14289_2" clause="2" testNumber="1"/>
                        <description>Rule 2</description>
                        <test>test2</test>
                        <error><message>Error 2</message><arguments/></error>
                        <references/>
                    </rule>
                    <rule object="PDFont">
                        <id specification="ISO_14289_2" clause="3" testNumber="1"/>
                        <description>Rule 3</description>
                        <test>test3</test>
                        <error><message>Error 3</message><arguments/></error>
                        <references/>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        #expect(delegate.profile?.rules.count == 3)
        #expect(delegate.profile?.rules[0].object == "PDDocument")
        #expect(delegate.profile?.rules[1].object == "PDPage")
        #expect(delegate.profile?.rules[2].object == "PDFont")
    }

    // MARK: - Error Arguments

    @Test("Delegate parses multiple error arguments")
    func multipleErrorArguments() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules>
                    <rule object="PDDocument">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>Test</description>
                        <test>true</test>
                        <error>
                            <message>Error with %1, %2, and %3</message>
                            <arguments>
                                <argument>firstArg</argument>
                                <argument>secondArg</argument>
                                <argument>thirdArg</argument>
                            </arguments>
                        </error>
                        <references/>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        let args = delegate.profile?.rules[0].error.arguments ?? []
        #expect(args.count == 3)
        #expect(args[0].name == "firstArg")
        #expect(args[1].name == "secondArg")
        #expect(args[2].name == "thirdArg")
    }

    // MARK: - References

    @Test("Delegate parses multiple references")
    func multipleReferences() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>Test</name>
                    <description>Test</description>
                </details>
                <rules>
                    <rule object="PDDocument">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>Test</description>
                        <test>true</test>
                        <error>
                            <message>Error</message>
                            <arguments/>
                        </error>
                        <references>
                            <reference specification="ISO 14289-2:2024" clause="8.2"/>
                            <reference specification="ISO 32000-2:2020" clause="14.7"/>
                        </references>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        let refs = delegate.profile?.rules[0].references ?? []
        #expect(refs.count == 2)
        #expect(refs[0].specification == "ISO 14289-2:2024")
        #expect(refs[0].clause == "8.2")
        #expect(refs[1].specification == "ISO 32000-2:2020")
        #expect(refs[1].clause == "14.7")
    }

    // MARK: - Missing Flavour

    @Test("Delegate sets error for missing flavour")
    func missingFlavour() {
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

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        // Parse completes but no profile is set
        _ = parser.parse()
        #expect(delegate.profile == nil)
        #expect(delegate.parseError != nil)
    }

    // MARK: - Specification Parsing

    @Test("Delegate parses all specification types")
    func allSpecificationTypes() {
        let specs: [(String, Specification)] = [
            ("ISO_19005_1", .iso190051),
            ("ISO_19005_2", .iso190052),
            ("ISO_19005_3", .iso190053),
            ("ISO_19005_4", .iso190054),
            ("ISO_14289_1", .iso142891),
            ("ISO_14289_2", .iso142892)
        ]

        for (rawValue, expected) in specs {
            let xml = """
                <?xml version="1.0" encoding="UTF-8"?>
                <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                    <details creator="Test" created="2024-01-01T00:00:00Z">
                        <name>Test</name>
                        <description>Test</description>
                    </details>
                    <rules>
                        <rule object="PDDocument">
                            <id specification="\(rawValue)" clause="1" testNumber="1"/>
                            <description>Test</description>
                            <test>true</test>
                            <error><message>Error</message><arguments/></error>
                            <references/>
                        </rule>
                    </rules>
                </profile>
                """

            let delegate = ProfileXMLDelegate()
            let parser = XMLParser(data: xml.data(using: .utf8)!)
            parser.delegate = delegate

            #expect(parser.parse(), "Failed to parse XML with specification \(rawValue)")
            #expect(delegate.profile?.rules[0].id.specification == expected,
                   "Expected \(expected) for \(rawValue)")
        }
    }

    // MARK: - Whitespace Handling

    @Test("Delegate trims whitespace from text content")
    func whitespaceTrimmming() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <profile xmlns="http://www.verapdf.org/ValidationProfile" flavour="PDFUA_2">
                <details creator="Test" created="2024-01-01T00:00:00Z">
                    <name>
                        Test Name With Whitespace
                    </name>
                    <description>
                        Description
                    </description>
                </details>
                <rules>
                    <rule object="PDDocument">
                        <id specification="ISO_14289_2" clause="1" testNumber="1"/>
                        <description>
                            Rule description
                        </description>
                        <test>
                            testExpression == true
                        </test>
                        <error>
                            <message>
                                Error message
                            </message>
                            <arguments/>
                        </error>
                        <references/>
                    </rule>
                </rules>
            </profile>
            """

        let delegate = ProfileXMLDelegate()
        let parser = XMLParser(data: xml.data(using: .utf8)!)
        parser.delegate = delegate

        #expect(parser.parse())
        #expect(delegate.profile?.details.name == "Test Name With Whitespace")
        #expect(delegate.profile?.rules[0].description == "Rule description")
        #expect(delegate.profile?.rules[0].test == "testExpression == true")
    }
}
