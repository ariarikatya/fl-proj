abstract class CustomException implements Exception {
  CustomException(this.message, [this.originalException]);
  final String message;
  final Exception? originalException;

  @override
  String toString() {
    return super.toString() + '\nMessage: $message\nOriginal exception: $originalException';
  }
}

class PhotoUploadException extends CustomException {
  PhotoUploadException() : super('Произошла ошибка при загрузке фото');
}

class PhotoPickException extends CustomException {
  PhotoPickException(Exception? platformException) : super('Произошла ошибка при выборе фото', platformException);
}

class PermissionDeniedException extends CustomException {
  PermissionDeniedException(super.message);
}
