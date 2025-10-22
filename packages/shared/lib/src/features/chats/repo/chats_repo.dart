import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class ChatsRepository {
  Future<Result<List<ChatPreview>>> getChats();
  Future<Result<List<ChatMessage>>> getChatHistory(int chatId, {int limit, int offset});
  Future<Result<bool>> readAllMessages(int chatId);
  Future<Result<ChatPreview>> startChat(int masterId, String message);
}

final class RestChatsRepository extends ChatsRepository {
  RestChatsRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<List<ChatPreview>>> getChats() => tryCatch(() async {
    final response = await dio.get('/chats');
    return parseJsonList(response.data['chats'], ChatPreview.fromJson);
  });

  @override
  Future<Result<List<ChatMessage>>> getChatHistory(int chatId, {int limit = 20, int offset = 0}) => tryCatch(() async {
    final params = {'limit': limit, 'offset': offset};
    final response = await dio.get('/chats/$chatId/messages', queryParameters: params);
    return parseJsonList(response.data['messages'], ChatMessage.fromJson);
  });

  @override
  Future<Result<ChatPreview>> startChat(int masterId, String message) => tryCatch(() async {
    final response = await dio.post('/chats', data: {"master_id": masterId, "initial_message": message});
    return ChatPreview.fromJson(response.data['chats'].first);
  });

  @override
  Future<Result<bool>> readAllMessages(int chatId) => tryCatch(() async {
    await dio.put('/chats/$chatId/read');
    return true;
  });
}
