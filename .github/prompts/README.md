# Copilot Instructions for Mobile Money Fraud Detection Platform

This directory contains custom Copilot instructions tailored specifically for the Ghana Mobile Money Fraud Detection Platform built with Flutter and AWS.

## Files Overview

### `prompt.instructions.md`

Comprehensive prompt template that enforces a "plan-then-code" workflow with Flutter and mobile security considerations.

### How It Works

When you start any new Copilot chat in this workspace, the custom instructions from `.vscode/settings.json` automatically load, ensuring every conversation follows best practices for:

- **Security-first development** (fraud detection requires stringent security)
- **Flutter/Dart patterns** (GetX state management, widget composition)
- **Mobile app optimization** (performance, accessibility, cross-platform)
- **Plan-then-code workflow** (detailed planning before implementation)

## Usage Examples

### Starting a New Feature

```
I need to add SMS fraud detection using AWS Nova multimodal analysis
```

Copilot will automatically:

1. Create a detailed plan covering security, architecture, testing, and mobile considerations
2. Ask for your approval before proceeding
3. Implement step-by-step following Flutter best practices

### Bug Fixes

```
Fix memory leak in transaction history GetX controller
```

Copilot will:

1. Analyze the issue with GetX lifecycle considerations
2. Plan the fix with testing strategy
3. Implement with proper disposal patterns

### Security Enhancements

```
Implement biometric authentication for transaction verification
```

Copilot will:

1. Plan cross-platform biometric integration
2. Consider security implications and compliance
3. Design offline-capable authentication flow

## Automatic Behaviors

Every Copilot chat will automatically:

✅ **Follow plan-then-code workflow** - No coding without approved plans
✅ **Prioritize security** - Encryption, validation, authentication first
✅ **Use GetX patterns** - Proper state management and dependency injection  
✅ **Consider mobile constraints** - Performance, battery, accessibility
✅ **Include comprehensive testing** - Unit, widget, and integration tests
✅ **Document architectural decisions** - Clear explanations for choices

## Project-Specific Considerations

### Security Requirements

- All financial data encrypted (AES-256)
- API requests signed and rate-limited
- Biometric authentication for sensitive operations
- OWASP mobile security compliance
- PCI DSS consideration for payment data

### Performance Targets

- Fraud detection API calls: < 2 seconds
- UI interactions: < 100ms response time
- Cold app start: < 3 seconds
- App bundle size: < 50MB

### Mobile Standards

- Cross-platform iOS/Android compatibility
- WCAG 2.1 AA accessibility compliance
- Localization for Ghanaian languages
- Offline-first architecture with sync
- Progressive disclosure for complex features

## Customization

To modify the instructions:

1. **Edit prompt template**: Update `.github/prompts/prompt.instructions.md`
2. **Modify auto-instructions**: Update `github.copilot.chat.customInstructions` in `.vscode/settings.json`
3. **Add project rules**: Extend the custom instructions with new patterns or requirements

## Verification

To verify the instructions are working:

1. Start a new Copilot chat
2. Ask for help with any development task
3. Copilot should automatically create a detailed plan before coding
4. The plan should include security, mobile, and Flutter-specific considerations

## Troubleshooting

**Instructions not loading?**

- Ensure `.vscode/settings.json` exists and has proper JSON syntax
- Restart VS Code to reload settings
- Check that GitHub Copilot extension is enabled

**Missing project context?**

- Verify the `github.copilot.chat.customInstructions` section in settings
- Update the instruction text with any new project requirements

**Plan quality issues?**

- Refine the prompt template in `prompt.instructions.md`
- Add more specific examples for your use cases
- Include additional constraints or patterns
