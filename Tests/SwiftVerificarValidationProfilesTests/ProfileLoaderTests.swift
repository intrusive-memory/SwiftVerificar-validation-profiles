import Testing
import Foundation
@testable import SwiftVerificarValidationProfiles

@Suite("ProfileLoader Tests")
struct ProfileLoaderTests {

    // MARK: - Instance Creation

    @Test("ProfileLoader shared instance exists")
    func sharedInstanceExists() async {
        let loader = ProfileLoader.shared
        #expect(loader != nil)
    }

    @Test("ProfileLoader can be instantiated directly")
    func directInstantiation() async {
        let loader = ProfileLoader()
        #expect(loader != nil)
    }

    // MARK: - Cache Management

    @Test("Cache is initially empty")
    func cacheInitiallyEmpty() async {
        let loader = ProfileLoader()
        let count = await loader.cachedProfileCount
        #expect(count == 0)
    }

    @Test("clearCache removes all cached profiles")
    func clearCacheRemovesAll() async throws {
        let loader = ProfileLoader()

        // Load a profile to populate cache
        _ = try await loader.loadProfile(for: .pdfUA2)
        var count = await loader.cachedProfileCount
        #expect(count > 0)

        // Clear and verify
        await loader.clearCache()
        count = await loader.cachedProfileCount
        #expect(count == 0)
    }

    @Test("isCached returns correct status")
    func isCachedStatus() async throws {
        let loader = ProfileLoader()

        // Initially not cached
        var cached = await loader.isCached(.pdfUA2)
        #expect(!cached)

        // Load it
        _ = try await loader.loadProfile(for: .pdfUA2)

        // Now cached
        cached = await loader.isCached(.pdfUA2)
        #expect(cached)

        // Different flavour not cached
        cached = await loader.isCached(.pdfA1a)
        #expect(!cached)
    }

    @Test("cachedFlavours returns set of cached flavours")
    func cachedFlavoursReturnsCorrectSet() async throws {
        let loader = ProfileLoader()

        // Initially empty
        var flavours = await loader.cachedFlavours
        #expect(flavours.isEmpty)

        // Load some profiles
        _ = try await loader.loadProfile(for: .pdfUA2)
        _ = try await loader.loadProfile(for: .pdfUA1)

        flavours = await loader.cachedFlavours
        #expect(flavours.contains(.pdfUA2))
        #expect(flavours.contains(.pdfUA1))
        #expect(!flavours.contains(.pdfA1a))
    }

    // MARK: - Profile Loading

    @Test("Load PDF/UA-2 profile")
    func loadPDFUA2() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        #expect(profile.flavour == .pdfUA2)
        #expect(!profile.rules.isEmpty)
        #expect(profile.details.name.contains("PDF/UA-2"))
    }

    @Test("Load PDF/UA-1 profile")
    func loadPDFUA1() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA1)

        #expect(profile.flavour == .pdfUA1)
        #expect(!profile.rules.isEmpty)
    }

    @Test("Loaded profile is cached")
    func loadedProfileIsCached() async throws {
        let loader = ProfileLoader()

        // First load
        let profile1 = try await loader.loadProfile(for: .pdfUA2)

        // Verify cached
        let cached = await loader.isCached(.pdfUA2)
        #expect(cached)

        // Second load returns same data
        let profile2 = try await loader.loadProfile(for: .pdfUA2)
        #expect(profile1.rules.count == profile2.rules.count)
        #expect(profile1.details.name == profile2.details.name)
    }

    @Test("Loading multiple profiles caches all")
    func multipleProfilesCached() async throws {
        let loader = ProfileLoader()

        _ = try await loader.loadProfile(for: .pdfUA2)
        _ = try await loader.loadProfile(for: .pdfUA1)

        let count = await loader.cachedProfileCount
        #expect(count == 2)
    }

    // MARK: - Preloading

    @Test("Preload multiple profiles")
    func preloadMultiple() async throws {
        let loader = ProfileLoader()

        try await loader.preloadProfiles(for: [.pdfUA2, .pdfUA1])

        let pdfUA2Cached = await loader.isCached(.pdfUA2)
        let pdfUA1Cached = await loader.isCached(.pdfUA1)

        #expect(pdfUA2Cached)
        #expect(pdfUA1Cached)
    }

    @Test("Preload empty array succeeds")
    func preloadEmpty() async throws {
        let loader = ProfileLoader()

        try await loader.preloadProfiles(for: [])

        let count = await loader.cachedProfileCount
        #expect(count == 0)
    }

    // MARK: - Profile Content Verification

    @Test("PDF/UA-2 profile has rules with correct object types")
    func pdfUA2RuleObjectTypes() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        // Verify we have various object types
        let objectTypes = Set(profile.rules.map(\.object))

        // These should be present in PDF/UA-2
        #expect(objectTypes.contains("PDDocument") || objectTypes.contains("PDStructElem") ||
               objectTypes.contains("CosDocument") || objectTypes.contains("PDFUAIdentification"))
    }

    @Test("PDF/UA-2 profile has rules with test expressions")
    func pdfUA2RuleTests() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        // All rules should have non-empty test expressions
        for rule in profile.rules {
            #expect(!rule.test.isEmpty, "Rule \(rule.uniqueID) has empty test")
        }
    }

    @Test("PDF/UA-2 profile has rules with error messages")
    func pdfUA2RuleErrors() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        // All rules should have non-empty error messages
        for rule in profile.rules {
            #expect(!rule.error.message.isEmpty, "Rule \(rule.uniqueID) has empty error message")
        }
    }

    @Test("PDF/UA-2 profile has rules with correct specification")
    func pdfUA2RuleSpecification() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        // PDF/UA-2 rules should reference ISO 14289-2
        let hasUA2Rules = profile.rules.contains { $0.id.specification == .iso142892 }
        #expect(hasUA2Rules)
    }

    // MARK: - Profile Flavour Subdirectories

    @Test("PDF/UA profiles load from PDF_UA subdirectory")
    func pdfUASubdirectory() async throws {
        let loader = ProfileLoader()

        // These should all load from PDF_UA
        _ = try await loader.loadProfile(for: .pdfUA2)
        _ = try await loader.loadProfile(for: .pdfUA1)

        // Verify loaded (no exception means correct subdirectory)
        let ua2Cached = await loader.isCached(.pdfUA2)
        let ua1Cached = await loader.isCached(.pdfUA1)

        #expect(ua2Cached)
        #expect(ua1Cached)
    }

    // MARK: - Thread Safety

    @Test("Concurrent loads are safe")
    func concurrentLoads() async throws {
        let loader = ProfileLoader()

        // Load same profile concurrently
        async let profile1 = loader.loadProfile(for: .pdfUA2)
        async let profile2 = loader.loadProfile(for: .pdfUA2)
        async let profile3 = loader.loadProfile(for: .pdfUA2)

        let profiles = try await [profile1, profile2, profile3]

        // All should return the same data
        #expect(profiles[0].rules.count == profiles[1].rules.count)
        #expect(profiles[1].rules.count == profiles[2].rules.count)

        // Should only be cached once
        let count = await loader.cachedProfileCount
        #expect(count == 1)
    }

    @Test("Concurrent loads of different profiles are safe")
    func concurrentDifferentProfiles() async throws {
        let loader = ProfileLoader()

        async let ua2 = loader.loadProfile(for: .pdfUA2)
        async let ua1 = loader.loadProfile(for: .pdfUA1)

        let (profile1, profile2) = try await (ua2, ua1)

        #expect(profile1.flavour == .pdfUA2)
        #expect(profile2.flavour == .pdfUA1)

        let count = await loader.cachedProfileCount
        #expect(count == 2)
    }

    // MARK: - Profile Details

    @Test("Profile details are parsed correctly")
    func profileDetails() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        #expect(!profile.details.name.isEmpty)
        #expect(!profile.details.description.isEmpty)
        #expect(!profile.details.creator.isEmpty)
    }

    // MARK: - Rule Counting

    @Test("Profile has reasonable number of rules")
    func reasonableRuleCount() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        // PDF/UA-2 should have dozens of rules
        #expect(profile.rules.count >= 10, "Expected at least 10 rules in PDF/UA-2 profile")
        #expect(profile.rules.count <= 500, "Expected at most 500 rules in PDF/UA-2 profile")
    }

    // MARK: - Rule Uniqueness

    @Test("All rule IDs are unique within profile")
    func uniqueRuleIDs() async throws {
        let loader = ProfileLoader()
        let profile = try await loader.loadProfile(for: .pdfUA2)

        let uniqueIDs = Set(profile.rules.map(\.uniqueID))
        #expect(uniqueIDs.count == profile.rules.count,
               "Expected all rule IDs to be unique, but found duplicates")
    }
}
