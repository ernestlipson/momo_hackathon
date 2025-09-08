# Copilot Instructions Test

## Quick Test Cases

Use these sample requests to verify your Copilot instructions are working correctly:

### Test 1: Feature Request

```
Add a feature to scan QR codes for mobile money transfers
```

**Expected**: Copilot should create a detailed plan covering:

- Security considerations for QR code validation
- GetX controller architecture
- Camera permissions (iOS/Android)
- UI/UX design with accessibility
- Testing strategy
- Integration with fraud detection

### Test 2: Bug Fix

```
The app crashes when users try to view transaction history on older Android devices
```

**Expected**: Copilot should plan:

- Root cause analysis approach
- GetX lifecycle considerations
- Memory management strategies
- Cross-platform testing plan
- Performance optimization

### Test 3: Security Enhancement

```
Implement end-to-end encryption for SMS transaction data
```

**Expected**: Copilot should address:

- Encryption algorithms and key management
- AWS integration for secure storage
- Compliance requirements (PCI DSS)
- Performance impact analysis
- Cross-platform implementation

## Verification Checklist

✅ **Plan-First Workflow**: Copilot creates detailed plans before coding
✅ **Security Focus**: Every plan includes security considerations
✅ **Flutter Patterns**: Plans mention GetX, controllers, widgets
✅ **Mobile Considerations**: Cross-platform, performance, accessibility
✅ **Testing Strategy**: Unit, widget, and integration tests included
✅ **Project Context**: References fraud detection and Ghana mobile money

## Success Indicators

If the instructions are working correctly, Copilot will:

1. **Always plan first** - Never jump straight to code
2. **Ask for approval** - Request permission before implementation
3. **Include security** - Address encryption, validation, auth in every plan
4. **Follow GetX patterns** - Use proper state management architecture
5. **Consider mobile constraints** - Performance, battery, accessibility
6. **Reference project context** - Ghana, mobile money, fraud detection

## Failure Indicators

If you see these behaviors, the instructions may not be loaded:

❌ Copilot jumps straight to code without planning
❌ Plans lack security considerations
❌ No mention of GetX or Flutter best practices
❌ Missing mobile-specific considerations
❌ Generic responses without project context
