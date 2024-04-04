class Constants {
  static String apiBaseUrl = "https://bdew32324.webturtle.fr";
  static String uriAuthentification = "$apiBaseUrl/auth/login";
  static String uriArticles = "$apiBaseUrl/items/articles";
  static String uriLogout = "$apiBaseUrl/auth/logout";
  static String uriRefreshToken = "$apiBaseUrl/auth/refresh";

  static String storageKeyAccessToken = "bdew32324.access_token";
  static String storageKeyRefreshToken = "bdew32324.refresh_token";
  static String storageKeyTokenExpire = "bdew32324.token_expiration";

  static String directusAuthenticatedUserRole =
      "3d1cdd82-7531-42db-a5cd-21a455179590";
  static String directusUserCreatorToken = "phCG4_53ZGOShDuE1J3-pw27exBM7FBm";
  static String uriUsers = "$apiBaseUrl/users";
}
