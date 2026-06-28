// Key names for flutter_secure_storage — keeps strings in one place
class StorageKeys {
  StorageKeys._();

  static const accessToken = 'ems_access_token'; // Short-lived JWT for API calls
  static const refreshToken = 'ems_refresh_token'; // Long-lived token to get new access token
  static const username = 'ems_username'; // Display name in UI
  static const role = 'ems_role'; // ROLE_ADMIN or ROLE_USER — controls delete buttons
}
