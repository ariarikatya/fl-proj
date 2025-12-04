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
        return Result.ok(1);
        // logger.info('Opening support screen with credentials: email=$email, name=$name');
        // final dio = DioFactory.createDio(baseUrl: 'https://polka.helpdeskeddy.com/api')
        //   ..options.headers['Authorization'] =
        //       'Basic ${'YmFiYXJ5a2luMjAwM0B5YW5kZXgucnU6YWQ4ZDRiOGItZjQwZi00NDRmLTlhOGUtNjhiNTM0MTgwMTU1'}';
        // try {
        //   final body = {'email': 'email@test.com', 'name': name};
        //   final response = await dio.post('/v2/chat/visitor/id', data: body);
        //   return Result.ok(response.data['data']['id'] as String);
        // } catch (e, st) {
        //   return Result<String>.err(e, st);
        // }
      },
      // builder: (sessionId) => _View(sessionId: sessionId, name: name, email: email),
      builder: (sessionId) => _View(name: name, email: email),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.name, required this.email});

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
          // _initChat();
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
    ..loadRequest(Uri.parse('https://polka.helpdeskeddy.com/ru/omnichannel/chat/'));

  void _initChat() async {
    List results = [];

    // await Future.delayed(Duration(seconds: 1));
    logger.debug('running addCustomChatButtons');
    results.add(
      await controller.runJavaScriptReturningResult(
        "window.postMessage({type: 'addCustomChatButtons',payload: {id: 'invoices', buttons: [{text: 'ID123'}, {text: 'ID321'}, {text: 'ID456'}]}})",
      ),
    );

    // await Future.delayed(Duration(seconds: 1));
    logger.debug('running setInitialMessage');
    results.add(
      await controller.runJavaScriptReturningResult(
        'window.postMessage({type: "setInitialChatMessage", payload: "Добро пожаловать в чат поддержки Polka"});',
      ),
    );

    await Future.delayed(Duration(seconds: 1));
    logger.debug('running init');
    results.add(
      await controller.runJavaScriptReturningResult(
        // "window.postMessage({type: 'init', payload: {name: '${widget.name}', email: '${widget.email}'}});",
        "window.postMessage({type: 'init', payload: {name: 'Николай', email: 'homecomp2018@gmail.com'}});",
      ),
    );
    logger.debug(results);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: _title),
      child: WebViewWidget(controller: controller),
    );
  }
}
