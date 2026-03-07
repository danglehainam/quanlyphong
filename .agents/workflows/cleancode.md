---
description: Standard Development & Maintenance Workflow (Clean Architecture & UI Design) for ChuNha Project (/cleancode)
---

When developing new features or performing refactoring in the ChuNha project, strictly adhere to the following professional workflow:

### // turbo-all

## Step 0: Preparation & Design (Database First)
- Before coding, read or update the `docs/database.md` documentation.
- Ensure a clear understanding of the Entity Schema (field names, data types, parent-child relationships).

## Step 1: Domain Layer (Requirements & Business Logic)
Always start from the "Heart" of the application (innermost layer).
1. **Entity**: Create the file at `lib/domain/entities/[name]_entity.dart`.
    - Must be a plain class with `final` properties.
    - **FORBIDDEN**: Do NOT import any files from the Data or Presentation layers.
2. **Repository Interface**: Define the interface (contract) at `lib/domain/repositories/`.
3. **UseCase**: Create single-responsibility classes at `lib/domain/usecases/`.
4. **Failure**: Define business-specific errors at `lib/core/error/failures.dart`.

## Step 2: Data Layer (Structure & Data Access)
Bridge the application to the external world (Firestore).
1. **Model**: Create the file at `lib/data/models/[name]_model.dart`.
    - **GOLDEN RULE**: Absolutely DO NOT `extends` from the Entity.
    - Must include all mappers: `fromFirestore`, `toFirestore`, `toEntity`, and `fromEntity`.
2. **DataSource**: Implement direct Firestore calls at `lib/data/datasources/remote/`. 
3. **Repository Implementation**: Implement the Domain interface at `lib/data/repositories/`. 
    - **Responsibility**: Call the DataSource, catch errors and map them to `Failure`, and transform Data <=> Entity using mappers before returning data.

## Step 3: Presentation Layer (UI & UI Logic)
1. **BLoC**: Manage state logic at `lib/presentation/bloc/`. 
    - Clearly separate `Event`, `State`, and `Bloc`.
    - **CRITICAL**: For Streams (Firestore), ALWAYS use `emit.forEach` instead of `Stream.listen`. 
    - **CRITICAL**: Never call `emit` inside an unawaited callback or after the handler completes.
2. **Widgets & Composition**: Build the UI at `lib/presentation/screens/`.
    - **Priority**: Decompose screens into smaller components (Widgets) for maintainability and reuse.
    - **CRITICAL**: BEFORE creating a new widget, check `lib/presentation/widgets/` to REUSE existing ones (e.g., `EmptyDataWidget`, `AppTextField`, `AppDropdownField`, `AppDialogActions`, `AppSectionHeader`, `AppSnackBar`).
    - **Directory Structure**: 
        - Screen-specific widgets: `lib/presentation/screens/[screen_name]/widgets/`.
        - Shared widgets: `lib/presentation/widgets/`.
    - **COLOR RULE**: Mandatory use of the `AppColors` class from `lib/core/constants/app_colors.dart`.
    - **FORBIDDEN**: Do NOT hardcode hex color codes or use default Flutter `Colors.[name]` constants in UI code.

## Step 4: Dependency Injection (Wiring)
- Register components sequentially in `lib/core/di/dependency_injection.dart`:
  `DataSource -> Repository -> UseCase -> Bloc`.

## Step 5: Verification & Completion
1. **Unit Test**: Prioritize writing tests for UseCases and Repositories in the `test/` directory.
2. **Analysis**: Run `flutter analyze` to ensure clean code and no unused imports.
3. **Refactor**: Remove dead code and temporary files after completion.

---
**Note for AI**: Always maintain Model-Entity consistency through mapper functions. If a database field changes, update in order: `database.md` -> `Model` -> `Entity` -> `UI`.
