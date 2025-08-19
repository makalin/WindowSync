# Contributing to WindowSync

Thank you for your interest in contributing to WindowSync! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Git

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/WindowSync.git
   cd WindowSync
   ```
3. Open the project in Xcode:
   ```bash
   open WindowSync.xcodeproj
   ```

## Development

### Project Structure

```
WindowSync/
├── WindowSync.xcodeproj/     # Xcode project file
├── WindowSync/               # Main app source code
│   ├── Models/              # Data models
│   ├── Managers/            # Business logic managers
│   ├── Extensions/          # Swift extensions
│   └── Assets.xcassets/     # App assets
├── Tests/                   # Unit tests
├── Package.swift            # Swift Package Manager configuration
├── Makefile                 # Build automation
└── build.sh                 # Build script
```

### Building

#### Using Xcode
1. Open `WindowSync.xcodeproj` in Xcode
2. Select the "WindowSync" scheme
3. Press Cmd+R to build and run

#### Using Command Line
```bash
# Build release version
make build

# Build debug version
make debug

# Clean build artifacts
make clean

# Run tests
make test
```

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code formatting
- Maximum line length: 120 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Testing

- Write unit tests for new functionality
- Ensure all tests pass before submitting PR
- Run tests with: `make test`

## Submitting Changes

### Pull Request Process

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "Add feature: brief description"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub

### Commit Message Format

Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build/tooling changes

Examples:
```
feat(core): add window arrangement persistence
fix(ui): resolve layout issues on small screens
docs(readme): update installation instructions
```

## Areas for Contribution

### High Priority
- [ ] Improve window matching algorithm
- [ ] Add support for macOS Spaces
- [ ] Implement conflict resolution for sync
- [ ] Add keyboard shortcuts

### Medium Priority
- [ ] Create app icon
- [ ] Add localization support
- [ ] Improve error handling
- [ ] Add logging system

### Low Priority
- [ ] Add themes
- [ ] Create documentation website
- [ ] Add analytics (privacy-focused)

## Reporting Issues

### Bug Reports

When reporting bugs, please include:
- macOS version
- WindowSync version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Console logs if available

### Feature Requests

For feature requests:
- Describe the use case
- Explain why it's needed
- Suggest implementation approach
- Consider impact on existing features

## Code of Conduct

- Be respectful and inclusive
- Focus on the code, not the person
- Provide constructive feedback
- Help others learn and grow

## Questions?

If you have questions about contributing:
- Open an issue for general questions
- Join our discussions
- Check existing documentation

Thank you for contributing to WindowSync! 🚀
