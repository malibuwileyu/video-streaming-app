# ReelAI Development Backlog

This file tracks features, improvements, and tasks that are not currently prioritized but may be implemented in the future.

## Feature Ideas
- OAuth2 Authentication Integration
  ```dart
  // Future extension to AuthService
  extension OAuth2Support on FirebaseAuthService {
    Future<User?> signInWithGoogle();
    Future<User?> signInWithGithub();
    Future<User?> signInWithApple();  // iOS requirement
  }
  ```

## Technical Debt
- None yet

## Nice-to-Have Improvements
- None yet

## Known Issues
- None yet 