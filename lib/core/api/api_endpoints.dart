class ApiEndpoints {
  static const baseUrl = 'https://pixe.la';

  static String createUser() => '/v1/users';
  static String deleteUser(String username) => '/v1/users/$username';
  static String graphs(String username) => '/v1/users/$username/graphs';
  static String pixel(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/pixels';
  static String pixelToday(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/today';
  static String pixelOnDate(String username, String graphId, String yyyyMMdd) =>
      '/v1/users/$username/graphs/$graphId/$yyyyMMdd';
  static String add(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/add';
  static String subtract(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/subtract';
  static String addOnDate(String username, String graphId, String yyyyMMdd) =>
      '/v1/users/$username/graphs/$graphId/$yyyyMMdd/add';
  static String subtractOnDate(String username, String graphId, String yyyyMMdd) =>
      '/v1/users/$username/graphs/$graphId/$yyyyMMdd/subtract';
  static String graph(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId';
  static String graphHtml(String username, String graphId) =>
      'https://pixe.la/v1/users/$username/graphs/$graphId.html';
  static String userProfile(String username) =>
      'https://pixe.la/@$username';
}
