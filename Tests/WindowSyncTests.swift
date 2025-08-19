import XCTest
@testable import WindowSync

final class WindowSyncTests: XCTestCase {
    
    func testWindowArrangementCreation() {
        let windows = [
            WindowInfo(
                appBundleIdentifier: "com.example.app",
                appName: "Test App",
                windowTitle: "Test Window",
                frame: CGRect(x: 100, y: 100, width: 800, height: 600),
                isMinimized: false,
                isFullScreen: false,
                spaceIndex: 0
            )
        ]
        
        let arrangement = WindowArrangement(name: "Test Arrangement", windows: windows)
        
        XCTAssertEqual(arrangement.name, "Test Arrangement")
        XCTAssertEqual(arrangement.windows.count, 1)
        XCTAssertEqual(arrangement.windows.first?.appName, "Test App")
    }
    
    func testWindowArrangementPersistence() {
        let windows = [
            WindowInfo(
                appBundleIdentifier: "com.example.app",
                appName: "Test App",
                windowTitle: "Test Window",
                frame: CGRect(x: 100, y: 100, width: 800, height: 600),
                isMinimized: false,
                isFullScreen: false,
                spaceIndex: 0
            )
        ]
        
        let arrangement = WindowArrangement(name: "Test Arrangement", windows: windows)
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try! encoder.encode(arrangement)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedArrangement = try! decoder.decode(WindowArrangement.self, from: data)
        
        XCTAssertEqual(decodedArrangement.name, arrangement.name)
        XCTAssertEqual(decodedArrangement.windows.count, arrangement.windows.count)
    }
    
    func testUserDefaultsExtensions() {
        let userDefaults = UserDefaults.standard
        
        // Test default values
        userDefaults.registerDefaults()
        
        XCTAssertTrue(userDefaults.syncEnabled)
        XCTAssertTrue(userDefaults.autoSyncOnStartup)
        XCTAssertTrue(userDefaults.showNotifications)
        XCTAssertFalse(userDefaults.includeHiddenWindows)
    }
    
    func testExcludedApps() {
        let userDefaults = UserDefaults.standard
        
        // Test adding excluded app
        userDefaults.addExcludedApp("com.test.app")
        XCTAssertTrue(userDefaults.isAppExcluded("com.test.app"))
        
        // Test removing excluded app
        userDefaults.removeExcludedApp("com.test.app")
        XCTAssertFalse(userDefaults.isAppExcluded("com.test.app"))
    }
    
    static var allTests = [
        ("testWindowArrangementCreation", testWindowArrangementCreation),
        ("testWindowArrangementPersistence", testWindowArrangementPersistence),
        ("testUserDefaultsExtensions", testUserDefaultsExtensions),
        ("testExcludedApps", testExcludedApps)
    ]
}
