import Foundation

extension UserDefaults {
    
    // MARK: - Window Arrangements
    
    private enum Keys {
        static let savedArrangements = "WindowSync_SavedArrangements"
        static let lastSyncDate = "WindowSync_LastSyncDate"
        static let syncEnabled = "WindowSync_SyncEnabled"
        static let autoSyncOnStartup = "WindowSync_AutoSyncOnStartup"
        static let showNotifications = "WindowSync_ShowNotifications"
        static let includeHiddenWindows = "WindowSync_IncludeHiddenWindows"
        static let excludedApps = "WindowSync_ExcludedApps"
        static let defaultArrangement = "WindowSync_DefaultArrangement"
    }
    
    // MARK: - Arrangements
    
    var savedArrangements: [WindowArrangement] {
        get {
            guard let data = data(forKey: Keys.savedArrangements) else { return [] }
            do {
                return try JSONDecoder().decode([WindowArrangement].self, from: data)
            } catch {
                print("Failed to decode saved arrangements: \(error)")
                return []
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                set(data, forKey: Keys.savedArrangements)
            } catch {
                print("Failed to encode saved arrangements: \(error)")
            }
        }
    }
    
    func saveArrangement(_ arrangement: WindowArrangement) {
        var arrangements = savedArrangements
        if let index = arrangements.firstIndex(where: { $0.id == arrangement.id }) {
            arrangements[index] = arrangement
        } else {
            arrangements.append(arrangement)
        }
        savedArrangements = arrangements
    }
    
    func deleteArrangement(_ arrangement: WindowArrangement) {
        var arrangements = savedArrangements
        arrangements.removeAll { $0.id == arrangement.id }
        savedArrangements = arrangements
    }
    
    func getArrangement(by id: UUID) -> WindowArrangement? {
        return savedArrangements.first { $0.id == id }
    }
    
    func getArrangement(by name: String) -> WindowArrangement? {
        return savedArrangements.first { $0.name == name }
    }
    
    // MARK: - Sync Settings
    
    var lastSyncDate: Date? {
        get { object(forKey: Keys.lastSyncDate) as? Date }
        set { set(newValue, forKey: Keys.lastSyncDate) }
    }
    
    var syncEnabled: Bool {
        get { bool(forKey: Keys.syncEnabled) }
        set { set(newValue, forKey: Keys.syncEnabled) }
    }
    
    var autoSyncOnStartup: Bool {
        get { bool(forKey: Keys.autoSyncOnStartup) }
        set { set(newValue, forKey: Keys.autoSyncOnStartup) }
    }
    
    // MARK: - UI Settings
    
    var showNotifications: Bool {
        get { bool(forKey: Keys.showNotifications) }
        set { set(newValue, forKey: Keys.showNotifications) }
    }
    
    var includeHiddenWindows: Bool {
        get { bool(forKey: Keys.includeHiddenWindows) }
        set { set(newValue, forKey: Keys.includeHiddenWindows) }
    }
    
    // MARK: - App Settings
    
    var excludedApps: [String] {
        get { stringArray(forKey: Keys.excludedApps) ?? [] }
        set { set(newValue, forKey: Keys.excludedApps) }
    }
    
    var defaultArrangement: String? {
        get { string(forKey: Keys.defaultArrangement) }
        set { set(newValue, forKey: Keys.defaultArrangement) }
    }
    
    // MARK: - Utility Methods
    
    func addExcludedApp(_ bundleIdentifier: String) {
        var excluded = excludedApps
        if !excluded.contains(bundleIdentifier) {
            excluded.append(bundleIdentifier)
            excludedApps = excluded
        }
    }
    
    func removeExcludedApp(_ bundleIdentifier: String) {
        var excluded = excludedApps
        excluded.removeAll { $0 == bundleIdentifier }
        excludedApps = excluded
    }
    
    func isAppExcluded(_ bundleIdentifier: String) -> Bool {
        return excludedApps.contains(bundleIdentifier)
    }
    
    // MARK: - Migration
    
    func migrateFromOldStorage() {
        // Check if we need to migrate from old storage format
        let oldKey = "WindowSync_Arrangements"
        if let oldData = data(forKey: oldKey) {
            do {
                let oldArrangements = try JSONDecoder().decode([WindowArrangement].self, from: oldData)
                savedArrangements = oldArrangements
                removeObject(forKey: oldKey)
                print("Successfully migrated \(oldArrangements.count) arrangements from old storage")
            } catch {
                print("Failed to migrate old arrangements: \(error)")
            }
        }
    }
    
    // MARK: - Reset
    
    func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        removePersistentDomain(forName: domain)
        synchronize()
    }
    
    func resetArrangements() {
        removeObject(forKey: Keys.savedArrangements)
        synchronize()
    }
    
    func resetSyncSettings() {
        removeObject(forKey: Keys.lastSyncDate)
        removeObject(forKey: Keys.syncEnabled)
        removeObject(forKey: Keys.autoSyncOnStartup)
        synchronize()
    }
    
    func resetUISettings() {
        removeObject(forKey: Keys.showNotifications)
        removeObject(forKey: Keys.includeHiddenWindows)
        synchronize()
    }
}

// MARK: - Default Values

extension UserDefaults {
    
    func registerDefaults() {
        let defaults: [String: Any] = [
            Keys.syncEnabled: true,
            Keys.autoSyncOnStartup: true,
            Keys.showNotifications: true,
            Keys.includeHiddenWindows: false,
            Keys.excludedApps: [
                "com.apple.finder",
                "com.apple.dock",
                "com.apple.menuBarExtra"
            ]
        ]
        
        register(defaults: defaults)
    }
}
