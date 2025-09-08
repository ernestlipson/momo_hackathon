---
mode: 'agent'
description: 'Always produce a detailed plan and get explicit approval before generating code.'
---
# Plan Then Code - Mobile Money Fraud Detection Platform

When I ask for help with a task, follow this workflow:

## Phase 1 — Planning (no code yet)
Produce a concise but detailed plan that includes:

### Core Planning Elements
- **Goal and scope** - What specific feature/fix and its boundaries
- **Assumptions and constraints** - Technical limitations, business rules, regulatory requirements
- **Risks and unknowns** - Security vulnerabilities, performance impacts, user experience concerns
- **Deliverables** - Dart files, widgets, APIs, tests, documentation, migrations

### Flutter/Mobile Specific Considerations
- **State management** - GetX controllers, reactive patterns, dependency injection
- **Widget architecture** - UI components, responsive design, accessibility compliance
- **Navigation flow** - Route management, deep linking, back button handling
- **Performance** - Build optimization, memory usage, battery impact, startup time
- **Platform compatibility** - iOS/Android differences, device capabilities, OS versions

### Security & Privacy (Critical for Fraud Detection)
- **Data protection** - Encryption, secure storage, PII handling, GDPR/local compliance
- **Authentication** - Biometric auth, session management, token security
- **API security** - Request signing, rate limiting, input validation
- **Fraud prevention** - Anti-tampering, jailbreak detection, secure communication

### Technical Architecture
- **Proposed approach** - High-level steps with sub-steps and GetX patterns
- **Affected files/components** - Controllers, views, models, services, routes
- **API integration** - AWS services, error handling, offline capability
- **Database/storage** - Local storage strategy, caching, sync mechanisms
- **Alternatives considered** - With tradeoffs for performance, security, maintainability

### Quality Assurance
- **Test plan** - Unit tests (controllers/models), widget tests (UI), integration tests (E2E flows)
- **Acceptance criteria** - User stories, edge cases, error scenarios
- **Accessibility** - Screen reader support, keyboard navigation, color contrast
- **Localization** - Multi-language support, RTL layouts, cultural considerations

### Deployment & Monitoring
- **Observability/metrics** - Crash reporting, performance monitoring, fraud detection metrics
- **Rollout strategy** - Staged deployment, feature flags, rollback plans
- **Migration steps** - Data migration, backward compatibility, user communication
- **Effort estimate** - Development time, testing time, review cycles, dependencies

Then ask:
"Do you want me to proceed with implementation based on this plan? Reply 'yes' to proceed or suggest changes."

## Phase 2 — Implementation (only after approval)

### Development Guidelines
- **Follow GetX patterns** - Use GetxController for state, GetView for UI, proper dependency injection
- **Security first** - Validate all inputs, encrypt sensitive data, follow OWASP mobile guidelines
- **Implement step-by-step** - Following the approved plan with clear references to plan items
- **Keep changes atomic** - Small, verifiable commits with comprehensive tests
- **Flutter best practices** - Widget composition, const constructors, efficient rebuilds
- **Code organization** - Clear separation: controllers, views, models, services, routes

### Quality Checks
- **Test coverage** - Unit tests for business logic, widget tests for UI, integration for user flows
- **Performance validation** - Check build times, app size, memory usage, startup performance
- **Security review** - Validate authentication flows, API security, data protection measures
- **Accessibility audit** - Screen reader compatibility, keyboard navigation, semantic labels
- **Cross-platform testing** - iOS and Android functionality, UI consistency, platform-specific features

### Change Management
- **Reference plan items** - Each change should map to specific planning elements
- **Pause for scope changes** - If new information changes the plan, request updated approval
- **Document decisions** - Architecture choices, security considerations, performance trade-offs
- **Review integration points** - AWS services, third-party APIs, platform-specific code

## Context Inputs
Use these inputs to tailor the plan:

- **task**: ${input:task:Describe the specific feature, bug fix, or improvement needed}
- **stack**: Flutter 3.9+, Dart, GetX, AWS Nova, Fraud Detector, NestJS API
- **constraints**: ${input:constraints:Security requirements, performance limits, regulatory compliance}
- **scope**: ${input:scope:Which app areas are affected - UI, API, authentication, fraud detection}
- **platform**: ${input:platform:iOS, Android, or both - any platform-specific considerations}

## Usage Examples

### Feature Development
```
/plan-first task="Implement biometric authentication for transaction verification" 
constraints="Must work offline, comply with PCI DSS" 
scope="Authentication module and fraud detection"
platform="iOS and Android - use platform biometric APIs"
```

### Bug Fixes
```
/plan-first task="Fix GetX controller memory leak in transaction history" 
constraints="Zero downtime, maintain user session" 
scope="Transaction controller and related views"
platform="Both platforms affected"
```

### Security Enhancements
```
/plan-first task="Add SMS fraud detection using AWS Nova multimodal analysis" 
constraints="Real-time processing, data privacy compliance" 
scope="SMS processing service and fraud detection API"
platform="Android SMS permissions, iOS message filtering"
```

### Performance Optimization
```
/plan-first task="Optimize app startup time and reduce bundle size" 
constraints="Target <3s cold start, <50MB app size" 
scope="App initialization, lazy loading, asset optimization"
platform="Platform-specific optimization strategies"
```

## Mobile Money Fraud Detection Specific Guidelines

### Security Priorities
1. **Data Encryption** - All PII and financial data encrypted at rest and in transit
2. **API Security** - Request signing, rate limiting, input sanitization
3. **Authentication** - Multi-factor auth, biometric verification, session management
4. **Fraud Prevention** - Real-time transaction monitoring, pattern analysis, user behavior

### Performance Requirements
1. **Response Time** - Fraud detection API calls <2s, UI interactions <100ms
2. **Offline Capability** - Core features work without internet, sync when connected
3. **Battery Optimization** - Background processing, efficient network usage
4. **Memory Management** - Handle large transaction datasets, proper disposal

### User Experience Standards
1. **Accessibility** - WCAG 2.1 AA compliance, screen reader support
2. **Localization** - Support for local languages, currency formatting
3. **Progressive Disclosure** - Complex security features with clear explanations
4. **Error Handling** - Clear, actionable error messages, graceful degradation