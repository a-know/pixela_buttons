class ApiEndpoints {
  static const baseUrl = 'https://pixe.la';

  static String createUser() => '/v1/users';
  static String graphs(String username) => '/v1/users/$username/graphs';
  static String pixel(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/pixels';
  static String pixelToday(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/today';
  static String add(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/add';
  static String subtract(String username, String graphId) =>
      '/v1/users/$username/graphs/$graphId/subtract';
  static String graphHtml(String username, String graphId) =>
      'https://pixe.la/v1/users/$username/graphs/$graphId.html';
}
