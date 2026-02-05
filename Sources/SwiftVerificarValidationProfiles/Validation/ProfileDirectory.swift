import Foundation

/// Directory service for accessing validation profiles and rules.
///
/// `ProfileDirectory` provides a high-level interface for querying validation
/// profiles and filtering rules by object type, tags, and other criteria.
/// It leverages the cached ``ProfileLoader`` for efficient profile access.
///
/// ## Example
/// ```swift
/// let directory = ProfileDirectory.shared
///
/// // Get all PDF/UA-2 rules for PDDocument objects
/// let rules = try await directory.rules(
///     for: .pdDocument,
///     in: .pdfUA2
/// )
///
/// // Get all machine-checkable rules
/// let machineRules = try await directory.machineCheckableRules(in: .pdfUA2)
///
/// // Get rules with specific tags
/// let criticalRules = try await directory.rules(
///     tagged: .critical,
///     in: .pdfUA2
/// )
/// ```
public actor ProfileDirectory {

    /// The shared singleton instance.
    public static let shared = ProfileDirectory()

    /// The profile loader used to fetch profiles.
    private let loader: ProfileLoader

    /// Creates a new profile directory.
    ///
    /// - Parameter loader: The profile loader to use (default: shared instance).
    public init(loader: ProfileLoader = .shared) {
        self.loader = loader
    }

    /// Get all available PDF flavours that have bundled profiles.
    nonisolated public var availableFlavours: [PDFFlavour] {
        [
            .pdfUA2,
            .pdfUA1,
            .pdfA1a,
            .pdfA1b,
            .pdfA2a,
            .pdfA2b,
            .pdfA2u,
            .pdfA3a,
            .pdfA3b,
            .pdfA3u,
            .pdfA4,
            .pdfA4e,
            .pdfA4f,
            .wcag22
        ]
    }

    /// Load a complete validation profile for a flavour.
    ///
    /// - Parameter flavour: The PDF flavour to load.
    /// - Returns: The complete validation profile.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func profile(for flavour: PDFFlavour) async throws -> ValidationProfile {
        try await loader.loadProfile(for: flavour)
    }

    /// Get all rules for a specific PDF object type.
    ///
    /// - Parameters:
    ///   - objectType: The PDF object type to filter by.
    ///   - flavour: The PDF flavour to query.
    /// - Returns: An array of rules targeting the specified object type.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func rules(
        for objectType: PDFObjectType,
        in flavour: PDFFlavour
    ) async throws -> [ValidationRule] {
        let profile = try await loader.loadProfile(for: flavour)
        return profile.rules(for: objectType)
    }

    /// Get all rules that contain a specific tag.
    ///
    /// - Parameters:
    ///   - tag: The tag to filter by.
    ///   - flavour: The PDF flavour to query.
    /// - Returns: An array of rules containing the specified tag.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func rules(
        tagged tag: RuleTag,
        in flavour: PDFFlavour
    ) async throws -> [ValidationRule] {
        let profile = try await loader.loadProfile(for: flavour)
        return profile.rules(withAnyTag: [tag])
    }

    /// Get all rules that contain all of the specified tags.
    ///
    /// - Parameters:
    ///   - tags: The tags to filter by. A rule must contain all specified tags.
    ///   - flavour: The PDF flavour to query.
    /// - Returns: An array of rules containing all specified tags.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func rules(
        withAllTags tags: Set<RuleTag>,
        in flavour: PDFFlavour
    ) async throws -> [ValidationRule] {
        let profile = try await loader.loadProfile(for: flavour)
        return profile.rules(withAllTags: tags)
    }

    /// Get all rules that contain any of the specified tags.
    ///
    /// - Parameters:
    ///   - tags: The tags to filter by. A rule must contain at least one.
    ///   - flavour: The PDF flavour to query.
    /// - Returns: An array of rules containing at least one specified tag.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func rules(
        withAnyTag tags: Set<RuleTag>,
        in flavour: PDFFlavour
    ) async throws -> [ValidationRule] {
        let profile = try await loader.loadProfile(for: flavour)
        return profile.rules(withAnyTag: tags)
    }

    /// Get all machine-checkable rules (rules tagged with `.machine`).
    ///
    /// - Parameter flavour: The PDF flavour to query.
    /// - Returns: An array of machine-checkable rules.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func machineCheckableRules(
        in flavour: PDFFlavour
    ) async throws -> [ValidationRule] {
        try await rules(tagged: .machine, in: flavour)
    }

    /// Get all human-checkable rules (rules tagged with `.human`).
    ///
    /// - Parameter flavour: The PDF flavour to query.
    /// - Returns: An array of human-checkable rules.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func humanCheckableRules(
        in flavour: PDFFlavour
    ) async throws -> [ValidationRule] {
        try await rules(tagged: .human, in: flavour)
    }

    /// Get statistics about a profile.
    ///
    /// - Parameter flavour: The PDF flavour to analyze.
    /// - Returns: Statistics about the profile.
    /// - Throws: ``ProfileLoadError`` if the profile cannot be loaded.
    public func statistics(for flavour: PDFFlavour) async throws -> ProfileStatistics {
        let profile = try await loader.loadProfile(for: flavour)

        let machineCheckable = profile.rules(withAnyTag: [.machine]).count
        let humanCheckable = profile.rules(withAnyTag: [.human]).count
        let critical = profile.rules(withAnyTag: [.critical]).count

        var objectTypeCounts: [String: Int] = [:]
        for rule in profile.rules {
            objectTypeCounts[rule.object, default: 0] += 1
        }

        return ProfileStatistics(
            flavour: flavour,
            totalRules: profile.ruleCount,
            machineCheckableRules: machineCheckable,
            humanCheckableRules: humanCheckable,
            criticalRules: critical,
            uniqueObjectTypes: objectTypeCounts.count,
            objectTypeCounts: objectTypeCounts
        )
    }

    /// Clear the profile cache to free memory.
    public func clearCache() async {
        await loader.clearCache()
    }
}

/// Statistics about a validation profile.
public struct ProfileStatistics: Sendable {

    /// The PDF flavour these statistics describe.
    public let flavour: PDFFlavour

    /// The total number of rules in the profile.
    public let totalRules: Int

    /// The number of machine-checkable rules.
    public let machineCheckableRules: Int

    /// The number of human-checkable rules.
    public let humanCheckableRules: Int

    /// The number of critical rules.
    public let criticalRules: Int

    /// The number of unique object types covered.
    public let uniqueObjectTypes: Int

    /// Rule counts per object type.
    public let objectTypeCounts: [String: Int]

    /// Creates new profile statistics.
    public init(
        flavour: PDFFlavour,
        totalRules: Int,
        machineCheckableRules: Int,
        humanCheckableRules: Int,
        criticalRules: Int,
        uniqueObjectTypes: Int,
        objectTypeCounts: [String: Int]
    ) {
        self.flavour = flavour
        self.totalRules = totalRules
        self.machineCheckableRules = machineCheckableRules
        self.humanCheckableRules = humanCheckableRules
        self.criticalRules = criticalRules
        self.uniqueObjectTypes = uniqueObjectTypes
        self.objectTypeCounts = objectTypeCounts
    }
}
