import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileDetails Tests")
struct ProfileDetailsTests {

    // MARK: - Test Helpers

    /// Creates a fixed reference date for deterministic testing.
    private static func referenceDate() -> Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar(identifier: .gregorian).date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    // MARK: - Initialization

    @Test("ProfileDetails stores all fields correctly")
    func initialization() {
        let date = ProfileDetailsTests.referenceDate()
        let details = ProfileDetails(
            name: "PDF/UA-2 validation profile",
            description: "Validation rules for PDF/UA-2 (ISO 14289-2)",
            creator: "veraPDF Consortium",
            created: date
        )

        #expect(details.name == "PDF/UA-2 validation profile")
        #expect(details.description == "Validation rules for PDF/UA-2 (ISO 14289-2)")
        #expect(details.creator == "veraPDF Consortium")
        #expect(details.created == date)
    }

    @Test("ProfileDetails with different profile types")
    func differentProfiles() {
        let date = ProfileDetailsTests.referenceDate()

        let pdfUA = ProfileDetails(
            name: "PDF/UA-2",
            description: "PDF/UA-2 rules",
            creator: "veraPDF",
            created: date
        )
        let pdfA = ProfileDetails(
            name: "PDF/A-1b",
            description: "PDF/A-1b rules",
            creator: "veraPDF",
            created: date
        )
        let wcag = ProfileDetails(
            name: "WCAG 2.2",
            description: "WCAG 2.2 rules",
            creator: "veraPDF",
            created: date
        )

        #expect(pdfUA.name == "PDF/UA-2")
        #expect(pdfA.name == "PDF/A-1b")
        #expect(wcag.name == "WCAG 2.2")
    }

    @Test("ProfileDetails with empty strings")
    func emptyStrings() {
        let date = ProfileDetailsTests.referenceDate()
        let details = ProfileDetails(name: "", description: "", creator: "", created: date)

        #expect(details.name == "")
        #expect(details.description == "")
        #expect(details.creator == "")
    }

    // MARK: - Hashable

    @Test("Equal ProfileDetails are equal")
    func hashableEquality() {
        let date = ProfileDetailsTests.referenceDate()
        let details1 = ProfileDetails(name: "Test", description: "Desc", creator: "Me", created: date)
        let details2 = ProfileDetails(name: "Test", description: "Desc", creator: "Me", created: date)

        #expect(details1 == details2)
        #expect(details1.hashValue == details2.hashValue)
    }

    @Test("ProfileDetails with different names are not equal")
    func hashableInequalityName() {
        let date = ProfileDetailsTests.referenceDate()
        let details1 = ProfileDetails(name: "A", description: "Desc", creator: "Me", created: date)
        let details2 = ProfileDetails(name: "B", description: "Desc", creator: "Me", created: date)

        #expect(details1 != details2)
    }

    @Test("ProfileDetails with different dates are not equal")
    func hashableInequalityDate() {
        let date1 = Date(timeIntervalSince1970: 1000)
        let date2 = Date(timeIntervalSince1970: 2000)
        let details1 = ProfileDetails(name: "A", description: "Desc", creator: "Me", created: date1)
        let details2 = ProfileDetails(name: "A", description: "Desc", creator: "Me", created: date2)

        #expect(details1 != details2)
    }

    // MARK: - Codable

    @Test("ProfileDetails round-trips through JSON")
    func codableRoundTrip() throws {
        let date = ProfileDetailsTests.referenceDate()
        let original = ProfileDetails(
            name: "PDF/UA-2 validation profile",
            description: "Rules for PDF/UA-2",
            creator: "veraPDF Consortium",
            created: date
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ProfileDetails.self, from: data)

        #expect(decoded == original)
        #expect(decoded.name == "PDF/UA-2 validation profile")
        #expect(decoded.description == "Rules for PDF/UA-2")
        #expect(decoded.creator == "veraPDF Consortium")
        #expect(decoded.created == date)
    }

    @Test("ProfileDetails with secondsSince1970 date encoding")
    func codableSecondsSince1970() throws {
        let date = Date(timeIntervalSince1970: 1705276800) // 2024-01-15T00:00:00Z
        let original = ProfileDetails(
            name: "Test",
            description: "Desc",
            creator: "Creator",
            created: date
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(ProfileDetails.self, from: data)

        #expect(decoded.created == date)
    }
}
