class UserRoles {
  final Map<String, Map<String, bool>> permissions;

  UserRoles(this.permissions);

  bool canAccess(String screen, String action) {
    return permissions[screen]?[action] ?? false;
  }

  void setPermission(String screen, String action, bool value) {
    permissions.putIfAbsent(screen, () => {});
    permissions[screen]![action] = value;
  }
}
