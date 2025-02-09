# gtd_task_manager

```
                   +--------------------------+
                   |         View             |
                   | (Flutter Widgets, UI)    |
                   +-------------+------------+
                                 │
                                 ▼
                   +--------------------------+
                   |       ViewModel          |
                   |  (Riverpod Notifiers)    |
                   +-------------+------------+
                                 │
                                 ▼
                   +--------------------------+
                   |         Model            |
                   | (Freezed / JSON Serializable) |
                   +-------------+------------+
                                 │
                                 ▼
                   +--------------------------+
                   |   Repository / Services  |
                   | (Firebase / Notion API等)  |
                   +--------------------------+

```

```
GTDTaskManager/
├── pubspec.yaml
├── .env
└── lib/
    ├── main.dart
    ├── constants/
    │   └── notion_colors.dart
    ├── models/
    │   └── task.dart        // ※task.freezed.dart, task.g.dartは生成ファイル
    ├── repositories/
    │   ├── auth_repository.dart
    │   └── task_repository.dart
    ├── services/
    │   ├── firebase_initializer.dart
    │   └── notion_service.dart
    ├── viewmodels/
    │   ├── auth_viewmodel.dart
    │   └── task_viewmodel.dart   // ※必要に応じて実装
    └── views/
        ├── login_screen.dart
        ├── home_screen.dart
        └── settings_screen.dart

```