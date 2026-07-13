class ApiEndpoints {
  static const String tasks = '/api/tasks';
  
  static String taskDetail(String taskId) => '/api/tasks/$taskId';
  static String taskMessages(String taskId) => '/messages?task_id=$taskId';
  static String taskTransitions(String taskId) => '/status_transitions';
}
