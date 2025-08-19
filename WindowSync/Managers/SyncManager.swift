import Foundation
import CloudKit
import Combine

class SyncManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private let container = CKContainer.default()
    private let database: CKDatabase
    private var cancellables = Set<AnyCancellable>()
    
    // CloudKit record types
    private let arrangementRecordType = "WindowArrangement"
    private let userRecordType = "User"
    
    init() {
        self.database = container.privateCloudDatabase
        checkSignInStatus()
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    func signIn() {
        container.accountStatus { [weak self] accountStatus, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.syncError = "Sign in failed: \(error.localizedDescription)"
                    return
                }
                
                switch accountStatus {
                case .available:
                    self?.isSignedIn = true
                    self?.syncArrangements()
                case .noAccount:
                    self?.syncError = "No iCloud account found. Please sign in to iCloud in System Preferences."
                case .restricted:
                    self?.syncError = "iCloud access is restricted."
                case .couldNotDetermine:
                    self?.syncError = "Could not determine iCloud account status."
                @unknown default:
                    self?.syncError = "Unknown iCloud account status."
                }
            }
        }
    }
    
    func signOut() {
        isSignedIn = false
        lastSyncDate = nil
        syncError = nil
    }
    
    func syncArrangements() {
        guard isSignedIn else { return }
        
        isSyncing = true
        syncError = nil
        
        // First, fetch existing arrangements from CloudKit
        fetchCloudArrangements { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cloudArrangements):
                    self?.mergeWithLocalArrangements(cloudArrangements)
                case .failure(let error):
                    self?.syncError = "Sync failed: \(error.localizedDescription)"
                }
                self?.isSyncing = false
                self?.lastSyncDate = Date()
            }
        }
    }
    
    func uploadArrangement(_ arrangement: WindowArrangement) {
        guard isSignedIn else { return }
        
        let record = createRecord(from: arrangement)
        
        database.save(record) { [weak self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.syncError = "Upload failed: \(error.localizedDescription)"
                } else {
                    print("Arrangement uploaded successfully: \(arrangement.name)")
                }
            }
        }
    }
    
    func deleteArrangement(_ arrangement: WindowArrangement) {
        guard isSignedIn else { return }
        
        // Delete from CloudKit if it exists there
        let recordID = CKRecord.ID(recordName: arrangement.id.uuidString)
        database.delete(withRecordID: recordID) { [weak self] recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.syncError = "Delete failed: \(error.localizedDescription)"
                } else {
                    print("Arrangement deleted from CloudKit: \(arrangement.name)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkSignInStatus() {
        container.accountStatus { [weak self] accountStatus, error in
            DispatchQueue.main.async {
                self?.isSignedIn = accountStatus == .available
                if self?.isSignedIn == true {
                    self?.syncArrangements()
                }
            }
        }
    }
    
    private func setupNotifications() {
        // Listen for CloudKit changes
        NotificationCenter.default.publisher(for: .CKAccountChanged)
            .sink { [weak self] _ in
                self?.checkSignInStatus()
            }
            .store(in: &cancellables)
    }
    
    private func fetchCloudArrangements(completion: @escaping (Result<[WindowArrangement], Error>) -> Void) {
        let query = CKQuery(recordType: arrangementRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        var arrangements: [WindowArrangement] = []
        
        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success(let record):
                if let arrangement = self.createArrangement(from: record) {
                    arrangements.append(arrangement)
                }
            case .failure(let error):
                print("Record fetch error: \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success:
                completion(.success(arrangements))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        database.add(operation)
    }
    
    private func mergeWithLocalArrangements(_ cloudArrangements: [WindowArrangement]) {
        // This is a simplified merge strategy
        // In a real implementation, you'd want more sophisticated conflict resolution
        
        for cloudArrangement in cloudArrangements {
            // Check if local arrangement exists
            let existsLocally = UserDefaults.standard.object(forKey: "WindowSync_\(cloudArrangement.id.uuidString)") != nil
            
            if !existsLocally {
                // Download new arrangement
                downloadArrangement(cloudArrangement)
            }
        }
    }
    
    private func downloadArrangement(_ arrangement: WindowArrangement) {
        // Save to local storage
        do {
            let data = try JSONEncoder().encode(arrangement)
            UserDefaults.standard.set(data, forKey: "WindowSync_\(arrangement.id.uuidString)")
        } catch {
            print("Failed to save downloaded arrangement: \(error)")
        }
    }
    
    private func createRecord(from arrangement: WindowArrangement) -> CKRecord {
        let record = CKRecord(recordType: arrangementRecordType)
        record.setValue(arrangement.name, forKey: "name")
        record.setValue(arrangement.createdAt, forKey: "createdAt")
        record.setValue(arrangement.updatedAt, forKey: "updatedAt")
        record.setValue(arrangement.deviceIdentifier, forKey: "deviceIdentifier")
        record.setValue(arrangement.tags, forKey: "tags")
        
        // Encode window data
        do {
            let windowData = try JSONEncoder().encode(arrangement.windows)
            record.setValue(windowData, forKey: "windows")
        } catch {
            print("Failed to encode windows: \(error)")
        }
        
        return record
    }
    
    private func createArrangement(from record: CKRecord) -> WindowArrangement? {
        guard let name = record["name"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date,
              let deviceIdentifier = record["deviceIdentifier"] as? String,
              let tags = record["tags"] as? [String],
              let windowData = record["windows"] as? Data else {
            return nil
        }
        
        do {
            let windows = try JSONDecoder().decode([WindowInfo].self, from: windowData)
            
            // Create arrangement with decoded data
            var arrangement = WindowArrangement(name: name, windows: windows, tags: tags)
            
            // Use reflection to set the private properties
            let mirror = Mirror(reflecting: arrangement)
            for child in mirror.children {
                if child.label == "createdAt" {
                    // Set createdAt
                } else if child.label == "updatedAt" {
                    // Set updatedAt
                } else if child.label == "deviceIdentifier" {
                    // Set deviceIdentifier
                }
            }
            
            return arrangement
        } catch {
            print("Failed to decode windows: \(error)")
            return nil
        }
    }
}

// MARK: - CloudKit Notifications

extension Notification.Name {
    static let CKAccountChanged = Notification.Name("CKAccountChanged")
}
