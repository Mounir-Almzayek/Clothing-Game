import 'package:get/get.dart';
import '../async_manager.dart';
import '../data/models/stage.dart';
import '../data/models/user.dart';
import '../data/repository/roster_repository.dart';

enum SortMode { byName, byStars }

/// Controller to manage roster items using GetX and AsyncManager
class RosterController extends GetxController {
  /// Async manager for loading and updating the list of users
  final AsyncManager<List<User>> usersManager =
      AsyncManager<List<User>>(initialData: []);

  Rx<User?> selectedUser = Rx<User?>(null);
  Rx<Stage?> selectedStage = Rx<Stage?>(null);

  void selectStage(Stage stage) {
    selectedStage.value = stage;
  }

  final sortMode = SortMode.byName.obs;

  void toggleSortMode() {
    sortMode.value =
        sortMode.value == SortMode.byName ? SortMode.byStars : SortMode.byName;

    _sortUsersAccordingToMode();
  }

  void _sortUsersAccordingToMode() async {
    if (sortMode.value == SortMode.byName) {
      sortUsersAlphabetically();
    } else if (sortMode.value == SortMode.byStars) {
      sortUsersByStars();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  /// Load all users from local storage
  void loadUsers({
    void Function(List<User>)? onSuccess,
    void Function(Object)? onError,
  }) {
    usersManager.observeAsync(
      task: (_) => RosterRepository.loadAll(),
      onSuccess: (list) {
        onSuccess?.call(list);
      },
      onError: (e) {
        onError?.call(e);
      },
    );
    _sortUsersAccordingToMode();
  }

  /// Add a new user and refresh list
  Future<void> addUser(
    User user, {
    void Function(List<User>)? onSuccess,
    void Function(Object)? onError,
  }) async {
    await usersManager.observeAsync(
      task: (_) async {
        await RosterRepository.add(user);
        return RosterRepository.loadAll();
      },
      onSuccess: (list) {
        usersManager.refresh();
        onSuccess?.call(list);
      },
      onError: (e) {
        onError?.call(e);
      },
    );
    _sortUsersAccordingToMode();
  }

  /// Update existing user
  Future<void> updateUser(
    User user, {
    void Function(List<User>)? onSuccess,
    void Function(Object)? onError,
  }) async {
    await usersManager.observeAsync(
      task: (_) async {
        await RosterRepository.update(user);
        return RosterRepository.loadAll();
      },
      onSuccess: (list) {
        usersManager.refresh();
        onSuccess?.call(list);
      },
      onError: (e) {
        onError?.call(e);
      },
    );
  }

  /// Delete a user by id
  Future<void> deleteUser(
    String userId, {
    void Function(List<User>)? onSuccess,
    void Function(Object)? onError,
  }) async {
    await usersManager.observeAsync(
      task: (_) async {
        await RosterRepository.delete(userId);
        return RosterRepository.loadAll();
      },
      onSuccess: (list) {
        usersManager.refresh();
        onSuccess?.call(list);
      },
      onError: (e) {
        onError?.call(e);
      },
    );
    _sortUsersAccordingToMode();
  }

  /// Returns the user object with the given [userId], or `null` if not found.
  User? getUserById(String userId) {
    final list = usersManager.value.value ?? [];
    for (final user in list) {
      if (user.id == userId) return user;
    }
    return null;
  }

  /// Increment a specific stage for a user
  Future<void> incrementUserStage(
    String userId,
    int stageId, {
    void Function(List<User>)? onSuccess,
    void Function(Object)? onError,
  }) async {
    await usersManager.observeAsync(
      task: (_) async {
        await RosterRepository.incrementStage(userId, stageId);
        return RosterRepository.loadAll();
      },
      onSuccess: (list) {
        usersManager.refresh();
        selectedUser.value = getUserById(selectedUser.value!.id);
        selectedUser.refresh();
        selectedStage.refresh();
        onSuccess?.call(list);
      },
      onError: (e) {
        onError?.call(e);
      },
    );
  }

  /// Complete a specific stage for a user
  Future<void> completeUserStage(
    String userId,
    int stageId, {
    void Function(List<User>)? onSuccess,
    void Function(Object)? onError,
  }) async {
    await usersManager.observeAsync(
      task: (_) async {
        await RosterRepository.completeStage(userId, stageId);
        return RosterRepository.loadAll();
      },
      onSuccess: (list) {
        selectedUser.refresh();
        onSuccess?.call(list);
      },
      onError: (e) {
        onError?.call(e);
      },
    );
  }

  /// Check if a stage is locked for a user
  Future<bool> isStageLocked(
    String userId,
    int stageId,
  ) async {
    return await RosterRepository.isStageLocked(userId, stageId);
  }

  /// Get number of completed stars for a user
  Future<int> getCompletedStars(
    String userId,
  ) async {
    return await RosterRepository.completedStars(userId);
  }

  /// Sort users alphabetically (A-Z)
  void sortUsersAlphabetically() {
    final list = usersManager.value.value ?? [];
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    usersManager.setData(list);
    usersManager.refresh();
  }

  /// Sort users by completed stages count (stars) descending
  Future<void> sortUsersByStars() async {
    final list = usersManager.value.value ?? [];
    final entries = <MapEntry<User, int>>[];
    for (final u in list) {
      final stars = await getCompletedStars(u.id);
      entries.add(MapEntry(u, stars));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    final sorted = entries.map((e) => e.key).toList();
    usersManager.setData(sorted);
    usersManager.refresh();
  }

  /// Returns a map where key = number of stars (0 to 3), value = number of users
  Future<Map<int, int>> getUserStarDistribution() async {
    final list = usersManager.value.value ?? [];
    final result = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};

    for (final user in list) {
      final stars = await getCompletedStars(user.id);
      if (stars >= 0 && stars <= 3) {
        result[stars] = result[stars]! + 1;
      }
    }
    return result;
  }
}
