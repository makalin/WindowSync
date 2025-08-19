import SwiftUI

struct ContentView: View {
    @StateObject private var windowManager = WindowManager()
    @StateObject private var syncManager = SyncManager()
    @State private var showingSaveDialog = false
    @State private var arrangementName = ""
    @State private var selectedArrangement: WindowArrangement?
    @State private var showingDeleteAlert = false
    @State private var arrangementToDelete: WindowArrangement?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "rectangle.3.group.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("WindowSync")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Sync your workspace across devices")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Save Current Layout Button
            Button(action: {
                showingSaveDialog = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Save Current Layout")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Saved Arrangements List
            VStack(alignment: .leading, spacing: 12) {
                Text("Saved Arrangements")
                    .font(.headline)
                    .padding(.horizontal)
                
                if windowManager.savedArrangements.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.3.group")
                            .font(.system(size: 30))
                            .foregroundColor(.secondary)
                        Text("No arrangements saved yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(windowManager.savedArrangements) { arrangement in
                                ArrangementRow(
                                    arrangement: arrangement,
                                    onLoad: {
                                        windowManager.loadArrangement(arrangement)
                                    },
                                    onDelete: {
                                        arrangementToDelete = arrangement
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            // Sync Status
            if syncManager.isSignedIn {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(.green)
                        Text("Synced to iCloud")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Sign Out") {
                        syncManager.signOut()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            } else {
                Button("Sign in to iCloud") {
                    syncManager.signIn()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
        .alert("Save Arrangement", isPresented: $showingSaveDialog) {
            TextField("Arrangement name", text: $arrangementName)
            Button("Save") {
                if !arrangementName.isEmpty {
                    windowManager.saveCurrentArrangement(name: arrangementName)
                    arrangementName = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for this window arrangement")
        }
        .alert("Delete Arrangement", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let arrangement = arrangementToDelete {
                    windowManager.deleteArrangement(arrangement)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(arrangementToDelete?.name ?? "")'?")
        }
    }
}

struct ArrangementRow: View {
    let arrangement: WindowArrangement
    let onLoad: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(arrangement.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(arrangement.windows.count) windows")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(arrangement.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onLoad) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Auto-sync on startup", isOn: .constant(true))
                Toggle("Show notifications", isOn: .constant(true))
                Toggle("Include hidden windows", isOn: .constant(false))
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
}
