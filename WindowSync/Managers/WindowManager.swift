import Foundation
import Cocoa
import ApplicationServices

class WindowManager: ObservableObject {
    @Published var savedArrangements: [WindowArrangement] = []
    
    private let userDefaults = UserDefaults.standard
    private let arrangementsKey = "WindowSync_SavedArrangements"
    
    init() {
        loadSavedArrangements()
    }
    
    // MARK: - Public Methods
    
    func saveCurrentArrangement(name: String) {
        guard let windows = getCurrentWindows() else {
            print("Failed to get current windows")
            return
        }
        
        let arrangement = WindowArrangement(name: name, windows: windows)
        savedArrangements.append(arrangement)
        saveArrangements()
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .arrangementSaved, object: arrangement)
    }
    
    func loadArrangement(_ arrangement: WindowArrangement) {
        guard AXIsProcessTrusted() else {
            requestAccessibilityPermissions()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            for windowInfo in arrangement.windows {
                self.restoreWindow(windowInfo)
            }
        }
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .arrangementLoaded, object: arrangement)
    }
    
    func deleteArrangement(_ arrangement: WindowArrangement) {
        savedArrangements.removeAll { $0.id == arrangement.id }
        saveArrangements()
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .arrangementDeleted, object: arrangement)
    }
    
    func cleanup() {
        // Cleanup any temporary resources
    }
    
    // MARK: - Private Methods
    
    private func getCurrentWindows() -> [WindowInfo]? {
        guard AXIsProcessTrusted() else { return nil }
        
        var windows: [WindowInfo] = []
        
        // Get all running applications
        let runningApps = NSWorkspace.shared.runningApplications
        
        for app in runningApps {
            guard app.activationPolicy == .regular else { continue }
            
            if let appWindows = getWindowsForApp(app) {
                windows.append(contentsOf: appWindows)
            }
        }
        
        return windows.isEmpty ? nil : windows
    }
    
    private func getWindowsForApp(_ app: NSRunningApplication) -> [WindowInfo]? {
        guard let pid = app.processIdentifier else { return nil }
        
        let appRef = AXUIElementCreateApplication(pid)
        var windowList: CFArray?
        
        let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &windowList)
        guard result == .success, let windows = windowList as? [AXUIElement] else { return nil }
        
        var windowInfos: [WindowInfo] = []
        
        for window in windows {
            if let windowInfo = createWindowInfo(from: window, app: app) {
                windowInfos.append(windowInfo)
            }
        }
        
        return windowInfos
    }
    
    private func createWindowInfo(from window: AXUIElement, app: NSRunningApplication) -> WindowInfo? {
        var value: CFTypeRef
        
        // Get window title
        var title = ""
        if AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &value) == .success {
            title = (value as? String) ?? ""
        }
        
        // Get window position and size
        var position = CGPoint.zero
        var size = CGSize.zero
        
        if AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &value) == .success {
            if let point = value as? CGPoint {
                position = point
            }
        }
        
        if AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &value) == .success {
            if let sizeValue = value as? CGSize {
                size = sizeValue
            }
        }
        
        // Get window state
        var isMinimized = false
        var isFullScreen = false
        
        if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &value) == .success {
            isMinimized = (value as? Bool) ?? false
        }
        
        if AXUIElementCopyAttributeValue(window, kAXFullscreenAttribute as CFString, &value) == .success {
            isFullScreen = (value as? Bool) ?? false
        }
        
        // Get space index (simplified - in real implementation you'd need to query Mission Control)
        let spaceIndex = 0 // Default to main space
        
        let frame = CGRect(origin: position, size: size)
        
        return WindowInfo(
            appBundleIdentifier: app.bundleIdentifier ?? "unknown",
            appName: app.localizedName ?? "Unknown App",
            windowTitle: title,
            frame: frame,
            isMinimized: isMinimized,
            isFullScreen: isFullScreen,
            spaceIndex: spaceIndex
        )
    }
    
    private func restoreWindow(_ windowInfo: WindowInfo) {
        // Find the running application
        let runningApps = NSWorkspace.shared.runningApplications
        guard let app = runningApps.first(where: { $0.bundleIdentifier == windowInfo.appBundleIdentifier }) else {
            print("App not running: \(windowInfo.appName)")
            return
        }
        
        // Activate the app
        app.activate(options: .activateIgnoringOtherApps)
        
        // Get the app's AXUIElement
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        var windowList: CFArray?
        
        guard AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &windowList) == .success,
              let windows = windowList as? [AXUIElement] else { return }
        
        // Find the matching window by title
        for window in windows {
            var value: CFTypeRef
            if AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &value) == .success,
               let title = value as? String,
               title == windowInfo.windowTitle {
                
                // Restore window position and size
                restoreWindowPosition(window, frame: windowInfo.frame)
                
                // Restore window state
                if windowInfo.isMinimized {
                    AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
                }
                
                if windowInfo.isFullScreen {
                    AXUIElementSetAttributeValue(window, kAXFullscreenAttribute as CFString, kCFBooleanTrue)
                }
                
                break
            }
        }
    }
    
    private func restoreWindowPosition(_ window: AXUIElement, frame: CGRect) {
        // Set position
        let position = frame.origin
        let positionValue = AXValueCreate(.cgPoint, &position)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        
        // Set size
        let size = frame.size
        let sizeValue = AXValueCreate(.cgSize, &size)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    // MARK: - Persistence
    
    private func saveArrangements() {
        do {
            let data = try JSONEncoder().encode(savedArrangements)
            userDefaults.set(data, forKey: arrangementsKey)
        } catch {
            print("Failed to save arrangements: \(error)")
        }
    }
    
    private func loadSavedArrangements() {
        guard let data = userDefaults.data(forKey: arrangementsKey) else { return }
        
        do {
            savedArrangements = try JSONDecoder().decode([WindowArrangement].self, from: data)
        } catch {
            print("Failed to load arrangements: \(error)")
            savedArrangements = []
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let arrangementSaved = Notification.Name("WindowSync_ArrangementSaved")
    static let arrangementLoaded = Notification.Name("WindowSync_ArrangementLoaded")
    static let arrangementDeleted = Notification.Name("WindowSync_ArrangementDeleted")
}
