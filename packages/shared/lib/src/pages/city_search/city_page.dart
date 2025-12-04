import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/src/app_dependencies.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/pages/city_search/city_search_cubit.dart';
import 'package:shared/src/widgets/app_page.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_form_field.dart';
import 'package:shared/src/widgets/appbars.dart';

class CityPage extends StatefulWidget {
  const CityPage({super.key, this.initialCity});

  final String? initialCity;

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  late final _focusNode = FocusNode();
  late final _controller = TextEditingController(text: widget.initialCity)..addListener(listener);
  late final _cubit = CitySearchCubit(dependencies.dio);

  void _search() => _cubit.search(_controller.text.trim());

  void listener() {
    if (_controller.text.trim().isNotEmpty) {
      _search();
    }
    // Assuming the user has finished typing; Anyway this will be throttled in the cubit
    Timer(Duration(milliseconds: 500), () => _search());
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCity != null) listener();
    SchedulerBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Выбери город', simplified: true),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: AppTextFormField(labelText: 'Твой город', focusNode: _focusNode, controller: _controller),
          ),
          Expanded(
            child: BlocBuilder<CitySearchCubit, CitySearchState>(
              bloc: _cubit,
              builder: (context, state) => switch (state) {
                CitySearchLoaded(:final data) => SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var city in data)
                          GestureDetector(
                            onTap: () {
                              logger.info('user picked city: ${city.toJson()}');
                              Navigator.pop(context, city);
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
                              ),
                              child: AppText(city.fullName, style: AppTextStyles.bodyLarge),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _ => SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}
