enum AppState { idle, loading, success, error }

extension AppStateExtension on AppState {
  bool get isIdle => this == AppState.idle;
  bool get isLoading => this == AppState.loading;
  bool get isSuccess => this == AppState.success;
  bool get isError => this == AppState.error;
}
