import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _title = 'Поддержка';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, required this.email, required this.name});

  final String email;
  final String name;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      title: _title,
      future: () async {
        logger.info('Opening support screen with credentials: email=$email, name=$name');
        final dio = DioFactory.createDio(baseUrl: 'https://polka.helpdeskeddy.com/api')
          ..options.headers['Authorization'] =
              'Basic ${'YmFiYXJ5a2luMjAwM0B5YW5kZXgucnU6YWQ4ZDRiOGItZjQwZi00NDRmLTlhOGUtNjhiNTM0MTgwMTU1'}';
        try {
          final body = {'email': email, 'name': name};
          final response = await dio.post('/v2/chat/visitor/id', data: body);
          return Result.ok(response.data['data']['id'] as String);
        } catch (e, st) {
          return Result<String>.err(e, st);
        }
      },
      builder: (sessionId) => _View(sessionId: sessionId, name: name, email: email),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.sessionId, required this.name, required this.email});

  final String sessionId;
  final String name;
  final String email;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          logger.info('progress: $progress');
        },
        onPageStarted: (String url) {
          logger.info('page started');
          _initChat();
        },
        onPageFinished: (String url) {
          logger.info('page finished');
        },
        onHttpError: (HttpResponseError error) => handleError(error, null, false),
        onWebResourceError: (WebResourceError error) {
          handleError(error.description, null, false);
          logger.warning((error.errorCode, error.description, error.errorType, error.isForMainFrame, error.url));
        },
      ),
    )
    ..setBackgroundColor(Colors.white24)
    ..loadRequest(Uri.parse('https://polka.helpdeskeddy.com/ru/omnichannel/chat/?id=${widget.sessionId}'));

  void _initChat() async {
    controller.runJavaScript(
      "window.postMessage({type: 'init', payload: {name: '${widget.name}', email: '${widget.email}'}});",
    );
    controller.runJavaScript(
      "window.postMessage({type: 'setInitialChatMessage', payload: 'Добро пожаловать в чат поддержки Polka'});",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: _title),
      child: WebViewWidget(controller: controller),
    );
  }
}
