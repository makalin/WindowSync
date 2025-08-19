# WindowSync

## Description

**WindowSync** is a macOS tool designed to sync window arrangements across multiple Macs, ensuring a consistent workspace wherever you work. It allows you to save your current window layout, including app positions and sizes, and load these setups on any Mac. This is particularly useful for remote workers, developers, and multi-taskers who switch between different devices.

Unlike existing window management tools like Magnet or Mosaic, which focus on single-device window management, WindowSync addresses the need for cross-device consistency, ensuring your workspace feels the same whether you're at home, work, or on the go.

## Features

- **Save and Name Window Arrangements**: Create and name custom layouts (e.g., "Work Setup," "Coding Mode").
- **Load Arrangements on Any Mac**: Automatically position apps as saved on any Mac linked to your account.
- **Sync Across Devices**: Seamlessly sync arrangements across all your Macs for a consistent experience.
- **Advanced Features (Planned)**:
  - Exclude specific apps from syncing.
  - Set default arrangements based on time or calendar events.
  - Integrate with macOS Spaces for Space-specific configurations.

## Why It’s Useful

WindowSync enhances productivity by maintaining your preferred workspace across devices. It fills a gap in the macOS ecosystem, as current tools focus on single-device window management rather than cross-device syncing. This is especially valuable for:

- Remote workers who switch between home and office Macs.
- Developers who need consistent coding environments.
- Content creators who rely on specific app layouts for workflows.

## Installation

### Prerequisites

- **macOS 13.0 (Ventura) or later**
- **Xcode 15.0 or later** (available from the Mac App Store)

### Build from Source

1. **Clone the repository:**
   ```bash
   git clone https://github.com/makalin/WindowSync.git
   cd WindowSync
   ```

2. **Build and run:**
   ```bash
   make build && make run
   ```

   Or open in Xcode:
   ```bash
   open WindowSync.xcodeproj
   ```

For detailed build instructions, see [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md).

### Distribution

WindowSync will be distributed via:
- Mac App Store (once available)
- Direct download from GitHub releases
- Homebrew (planned)

## Usage

Once released, using WindowSync will be straightforward:

1. **Save a Window Arrangement**:
   - Open the WindowSync app.
   - Click "Save Current Layout" and give it a name (e.g., "Work Setup").
   - The current positions and sizes of all open windows will be saved.

2. **Load a Saved Arrangement**:
   - On any Mac linked to your account, open WindowSync.
   - Select the desired arrangement from the list (e.g., "Work Setup").
   - Click "Load," and your apps will automatically reposition to match the saved layout.

3. **Sync Across Devices**:
   - Sign in with your account to sync arrangements across all your Macs.
   - Any new or updated arrangements will be available on all linked devices.

## Roadmap

- **v1.0 (Planned)**:
  - Core functionality: Save, load, and sync window arrangements.
  - Basic UI for managing arrangements.
- **v1.1 (Future)**:
  - Advanced features: App exclusion, time-based defaults, macOS Spaces integration.
- **v1.2 (Future)**:
  - Enhanced UI/UX, additional customization options.

## Development

### Building

```bash
# Build release version
make build

# Build debug version
make debug

# Run tests
make test

# Clean build artifacts
make clean

# Show all available targets
make help
```

### Project Structure

```
WindowSync/
├── WindowSync.xcodeproj/     # Xcode project
├── WindowSync/               # Source code
│   ├── Models/              # Data models
│   ├── Managers/            # Business logic
│   ├── Extensions/          # Swift extensions
│   └── Assets.xcassets/     # App assets
├── Tests/                   # Unit tests
├── Package.swift            # Swift Package Manager
└── Makefile                 # Build automation
```

## Contributing

We welcome contributions from the community! If you'd like to help shape WindowSync, please:

- Check our [Contribution Guide](CONTRIBUTING.md) for details.
- Explore open issues on our [GitHub issues page](https://github.com/makalin/WindowSync/issues).
- Submit pull requests or suggest features.

## License

WindowSync is licensed under the [MIT License](LICENSE).

## Contact

For inquiries, feedback, or to report issues, please:

- Visit [GitHub issues page](https://github.com/makalin/WindowSync/issues).
- Follow [@makalin](https://x.com/makalin) for updates.

Your Workspace, Anywhere: Seamlessly Synced with WindowSync
