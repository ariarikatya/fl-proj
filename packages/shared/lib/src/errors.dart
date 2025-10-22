abstract class CustomException implements Exception {
  CustomException(this.message);
  final String message;
}

class PhotoUploadException extends CustomException {
  PhotoUploadException() : super('Произошла ошибка при загрузке фото');
}
