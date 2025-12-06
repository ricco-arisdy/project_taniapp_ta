import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/api_response.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _mounted = true;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get mounted => _mounted;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Template method pattern untuk handle async operations
  Future<ApiResponse<T>?> executeAsync<T>(
    Future<ApiResponse<T>> Function() operation,
  ) async {
    try {
      setLoading(true);
      clearError();

      final response = await operation();

      if (!response.isSuccess) {
        setError(response.message);
        return null;
      }

      setLoading(false);
      return response;
    } catch (e) {
      setError('Terjadi kesalahan: ${e.toString()}');
      return null;
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
