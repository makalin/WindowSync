import Foundation
import CoreGraphics

struct WindowInfo: Codable, Identifiable {
    let id = UUID()
    let appBundleIdentifier: String
    let appName: String
    let windowTitle: String
    let frame: CGRect
    let isMinimized: Bool
    let isFullScreen: Bool
    let spaceIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case appBundleIdentifier, appName, windowTitle, frame, isMinimized, isFullScreen, spaceIndex
    }
    
    init(appBundleIdentifier: String, appName: String, windowTitle: String, frame: CGRect, isMinimized: Bool, isFullScreen: Bool, spaceIndex: Int) {
        self.appBundleIdentifier = appBundleIdentifier
        self.appName = appName
        self.windowTitle = windowTitle
        self.frame = frame
        self.isMinimized = isMinimized
        self.isFullScreen = isFullScreen
        self.spaceIndex = spaceIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appBundleIdentifier = try container.decode(String.self, forKey: .appBundleIdentifier)
        appName = try container.decode(String.self, forKey: .appName)
        windowTitle = try container.decode(String.self, forKey: .windowTitle)
        
        // Decode CGRect components separately since CGRect is not Codable
        let x = try container.decode(CGFloat.self, forKey: .frame)
        let y = try container.decode(CGFloat.self, forKey: .frame)
        let width = try container.decode(CGFloat.self, forKey: .frame)
        let height = try container.decode(CGFloat.self, forKey: .frame)
        frame = CGRect(x: x, y: y, width: width, height: height)
        
        isMinimized = try container.decode(Bool.self, forKey: .isMinimized)
        isFullScreen = try container.decode(Bool.self, forKey: .isFullScreen)
        spaceIndex = try container.decode(Int.self, forKey: .spaceIndex)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appBundleIdentifier, forKey: .appBundleIdentifier)
        try container.encode(appName, forKey: .appName)
        try container.encode(windowTitle, forKey: .windowTitle)
        
        // Encode CGRect components separately
        try container.encode(frame.origin.x, forKey: .frame)
        try container.encode(frame.origin.y, forKey: .frame)
        try container.encode(frame.size.width, forKey: .frame)
        try container.encode(frame.size.height, forKey: .frame)
        
        try container.encode(isMinimized, forKey: .isMinimized)
        try container.encode(isFullScreen, forKey: .isFullScreen)
        try container.encode(spaceIndex, forKey: .spaceIndex)
    }
}

struct WindowArrangement: Codable, Identifiable {
    let id = UUID()
    let name: String
    let windows: [WindowInfo]
    let createdAt: Date
    let updatedAt: Date
    let deviceIdentifier: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, windows, createdAt, updatedAt, deviceIdentifier, tags
    }
    
    init(name: String, windows: [WindowInfo], tags: [String] = []) {
        self.name = name
        self.windows = windows
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        self.tags = tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        windows = try container.decode([WindowInfo].self, forKey: .windows)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deviceIdentifier = try container.decode(String.self, forKey: .deviceIdentifier)
        tags = try container.decode([String].self, forKey: .tags)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(windows, forKey: .windows)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(deviceIdentifier, forKey: .deviceIdentifier)
        try container.encode(tags, forKey: .tags)
    }
    
    // Helper methods
    var windowCount: Int {
        return windows.count
    }
    
    var isFromCurrentDevice: Bool {
        let currentDeviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        return deviceIdentifier == currentDeviceId
    }
    
    func hasTag(_ tag: String) -> Bool {
        return tags.contains(tag)
    }
    
    func addTag(_ tag: String) -> WindowArrangement {
        var newTags = tags
        if !newTags.contains(tag) {
            newTags.append(tag)
        }
        return WindowArrangement(name: name, windows: windows, tags: newTags)
    }
    
    func removeTag(_ tag: String) -> WindowArrangement {
        let newTags = tags.filter { $0 != tag }
        return WindowArrangement(name: name, windows: windows, tags: newTags)
    }
}

// MARK: - Extensions for better CGRect handling
extension CGRect: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([CGFloat].self)
        guard array.count == 4 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "CGRect requires 4 CGFloat values")
        }
        self.init(x: array[0], y: array[1], width: array[2], height: array[3])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([origin.x, origin.y, size.width, size.height])
    }
}
