# WindowSync Build Instructions

This document provides step-by-step instructions for building and running WindowSync on macOS.

## Prerequisites

- **macOS 13.0 (Ventura) or later**
- **Xcode 15.0 or later** (available from the Mac App Store)
- **Git** (for cloning the repository)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/makalin/WindowSync.git
cd WindowSync
```

### 2. Build and Run

#### Option A: Using Make (Recommended)

```bash
# Build the project
make build

# Run the app
make run

# Or build and run in one command
make && make run
```

#### Option B: Using Xcode

```bash
# Open in Xcode
open WindowSync.xcodeproj

# Then press Cmd+R to build and run
```

#### Option C: Using Build Script

```bash
# Make script executable (first time only)
chmod +x build.sh

# Build the project
./build.sh
```

## Build Targets

The Makefile provides several useful targets:

```bash
make help          # Show all available targets
make build         # Build release version
make debug         # Build debug version
make clean         # Clean build artifacts
make test          # Run tests
make install       # Install to Applications folder
make package       # Create DMG package
```

## Project Structure

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
├── Makefile                 # Build automation
└── build.sh                 # Build script
```

## Troubleshooting

### Common Issues

#### 1. Build Errors

```bash
# Clean and rebuild
make clean
make build
```

#### 2. Permission Issues

```bash
# Make build script executable
chmod +x build.sh
```

#### 3. Xcode Issues

- Ensure Xcode is up to date
- Clean build folder: `make clean`
- Reset Xcode: `Product > Clean Build Folder`

#### 4. macOS Version Issues

- Ensure you're running macOS 13.0 or later
- Check deployment target in Xcode project settings

### Build Output

Successful builds will create:
- `build/WindowSync.app` - The built application
- `DerivedData/` - Xcode build artifacts

## Development

### Running Tests

```bash
make test
```

### Debug Build

```bash
make debug
```

### Continuous Integration

The project includes:
- Swift Package Manager support
- Xcode project configuration
- Automated build scripts
- Test suite

## Distribution

### Create DMG Package

```bash
make package
```

This creates `dist/WindowSync.dmg` for distribution.

### Install to Applications

```bash
make install
```

## Support

If you encounter build issues:

1. Check the [Issues](https://github.com/makalin/WindowSync/issues) page
2. Ensure all prerequisites are met
3. Try cleaning and rebuilding
4. Check Xcode console for detailed error messages

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.
