# Flutter Development Guide

## Architecture

- Clean architecture: domain → data → presentation
- Feature-based structure
- Riverpod 2.0+ for state management
- GoRouter for navigation

## State management

- Riverpod providers: Provider, StreamProvider, FutureProvider, NotifierProvider
- Keep providers in feature's `presentation/providers/` directory
- Patient-specific state in `patient/presentation/providers/`
- Doctor-specific state in `doctor/presentation/providers/`

## Widget composition

- Prefer `const` constructors everywhere possible
- Use `ConsumerWidget` / `ConsumerStatefulWidget` with Riverpod
- `RepaintBoundary` around expensive subtrees
- `IntrinsicHeight` + `Row` for left-accent card pattern

## Performance

- Const constructors reduce widget rebuilds
- Use `Clip.antiAlias` with `clipBehavior` for rounded clips
- Prefer `LayoutBuilder` over `MediaQuery` for component-level responsiveness
- `SliverAppBar` + `CustomScrollView` for collapsible headers

## Project: MedQuiz

Stack: Flutter 3.37+ · Riverpod 3 · GoRouter 17 · Firebase · fl_chart · google_fonts

Features: auth / doctor / patient / quiz — each with domain → data → presentation layers.

Key patterns:
- `Result<T,F>` type uses `switch` patterns, not `.when()`
- `AppConstants.selfServiceDoctorId = 'self'` sentinel for patient self-assigned quizzes
- Theme uses Poppins via `GoogleFonts.poppins().fontFamily` (centralized in `AppTypography`)
- Responsive breakpoint: `>= 720px` = tablet/desktop layout

Platform targets: web (primary for doctors), mobile (primary for patients).
