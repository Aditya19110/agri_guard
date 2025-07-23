# Contributing to AgriGuard Plus

First off, thank you for considering contributing to AgriGuard Plus! It's people like you that make this project a great tool for farmers and agricultural professionals worldwide. 🌱

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)
- [Feature Requests](#feature-requests)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK (included with Flutter)
- Git
- A GitHub account
- Basic knowledge of Flutter/Dart development

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/agri_gurad.git
   cd agri_gurad
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/Aditya19110/agri_gurad.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Set up Firebase** (for testing)
   - Create a test Firebase project
   - Add your configuration files
   - Enable Authentication and Firestore

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

- 🐛 **Bug fixes**
- ✨ **New features**
- 📚 **Documentation improvements**
- 🎨 **UI/UX enhancements**
- 🧪 **Test coverage improvements**
- 🌍 **Translations and localization**
- 🔧 **Performance optimizations**

### Before You Start

1. **Check existing issues** - Look for existing issues or create a new one
2. **Discuss major changes** - For significant features, please discuss first
3. **Keep changes focused** - One feature/fix per pull request
4. **Test your changes** - Ensure everything works as expected

## Development Workflow

### 1. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b bugfix/bug-description
```

### 2. Make Your Changes

- Write clean, readable code
- Follow the coding standards below
- Add tests for new functionality
- Update documentation as needed

### 3. Test Your Changes

```bash
# Run tests
flutter test

# Run the app and test manually
flutter run

# Check for formatting issues
flutter format .

# Analyze code
flutter analyze
```

### 4. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add crop disease severity levels"
# or
git commit -m "fix: resolve image upload issue on Android"
```

#### Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(prediction): add confidence threshold setting
fix(auth): resolve login validation issue
docs(readme): update installation instructions
style(theme): improve color contrast ratios
```

### 5. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create a pull request on GitHub
```

## Coding Standards

### Dart/Flutter Guidelines

1. **Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide**

2. **Use meaningful names**
   ```dart
   // Good
   final String diseaseDetectionResult = 'Bacterial Blight';
   
   // Bad
   final String result = 'Bacterial Blight';
   ```

3. **Add proper documentation**
   ```dart
   /// Analyzes the provided image for crop diseases using TensorFlow Lite.
   /// 
   /// Returns a [PredictionResult] containing the disease name, confidence
   /// score, and treatment recommendations.
   Future<PredictionResult> analyzeCropImage(File imageFile) async {
     // Implementation
   }
   ```

4. **Use const constructors when possible**
   ```dart
   // Good
   const Icon(Icons.agriculture, color: AppTheme.primaryGreen)
   
   // Bad
   Icon(Icons.agriculture, color: AppTheme.primaryGreen)
   ```

5. **Prefer composition over inheritance**

6. **Handle errors gracefully**
   ```dart
   try {
     final result = await diseaseDetectionService.analyze(image);
     return result;
   } catch (e) {
     logger.error('Disease detection failed: $e');
     throw PredictionException('Failed to analyze image: $e');
   }
   ```

### Project Structure

```
lib/
├── config/           # App configuration and themes
├── models/           # Data models
├── screens/          # UI screens
├── services/         # Business logic and API calls
├── widgets/          # Reusable UI components
├── utils/           # Utility functions
└── constants/       # App constants
```

### Code Organization

- **One class per file** (unless closely related)
- **Group imports** (dart:, package:, relative)
- **Use barrel exports** for clean imports
- **Separate business logic from UI**

## Testing Guidelines

### Unit Tests

```dart
// test/services/disease_detection_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_gurad/services/disease_detection_service.dart';

void main() {
  group('DiseaseDetectionService', () {
    late DiseaseDetectionService service;

    setUp(() {
      service = DiseaseDetectionService();
    });

    test('should detect bacterial blight correctly', () async {
      // Arrange
      final testImage = File('test/assets/bacterial_blight.jpg');

      // Act
      final result = await service.analyzeImage(testImage);

      // Assert
      expect(result.diseaseName, 'Bacterial Blight');
      expect(result.confidence, greaterThan(0.8));
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/disease_result_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_gurad/widgets/disease_result_card.dart';

void main() {
  testWidgets('DiseaseResultCard displays disease information', (tester) async {
    // Arrange
    const testResult = PredictionResult(
      diseaseName: 'Brown Spot',
      confidence: 0.95,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiseaseResultCard(result: testResult),
        ),
      ),
    );

    // Assert
    expect(find.text('Brown Spot'), findsOneWidget);
    expect(find.text('95%'), findsOneWidget);
  });
}
```

### Integration Tests

- Test complete user flows
- Test with real Firebase instances (test projects)
- Test on different devices and screen sizes

## Documentation

### Code Documentation

- **Document public APIs** with dartdoc comments
- **Include examples** in documentation
- **Keep comments up to date** with code changes

### README Updates

When adding new features:
- Update the features list
- Add setup instructions if needed
- Include screenshots for UI changes

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

1. **Clear title** describing the issue
2. **Environment details** (OS, device, Flutter version)
3. **Steps to reproduce** the bug
4. **Expected vs actual behavior**
5. **Screenshots/videos** if applicable
6. **Error logs** if available

### Bug Report Template

```markdown
**Bug Description**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- Device: [e.g. iPhone 12, Pixel 5]
- OS: [e.g. iOS 15.0, Android 11]
- Flutter Version: [e.g. 3.7.2]
- App Version: [e.g. 1.0.0]

**Additional Context**
Any other context about the problem.
```

## Feature Requests

### Feature Request Template

```markdown
**Feature Description**
A clear description of what you want to happen.

**Problem Statement**
What problem does this solve?

**Proposed Solution**
Describe your proposed solution.

**Alternatives Considered**
Other solutions you've considered.

**Additional Context**
Any other context, mockups, or screenshots.
```

## Review Process

### Pull Request Requirements

- [ ] Code follows project coding standards
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or properly documented)
- [ ] PR description clearly explains changes

### Review Criteria

- **Functionality** - Does it work as intended?
- **Code Quality** - Is it well-written and maintainable?
- **Performance** - Does it impact app performance?
- **Security** - Are there any security concerns?
- **User Experience** - Does it improve the user experience?

## Getting Help

### Questions and Support

- 💬 **GitHub Discussions** - For general questions
- 🐛 **GitHub Issues** - For bug reports
- 📧 **Email** - support@agriguardplus.com
- 📚 **Documentation** - Check the wiki first

### Community

- Be respectful and constructive
- Help others when you can
- Share your agricultural knowledge
- Provide feedback on proposals

## Recognition

Contributors will be:
- Listed in the README contributors section
- Mentioned in release notes for significant contributions
- Invited to be maintainers for consistent contributors

## Thank You! 🙏

Every contribution, no matter how small, makes a difference. Whether you're fixing a typo, adding a feature, or helping other contributors, you're helping improve agriculture technology worldwide.

Happy coding! 🌱💻
