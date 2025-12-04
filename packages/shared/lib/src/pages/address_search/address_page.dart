import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'package:shared/src/app_dependencies.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key, this.initialAddress});

  final Address? initialAddress;

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late final _focusNode = FocusNode();
  late final _controller = TextEditingController(text: widget.initialAddress?.searchQuery)..addListener(listener);
  late final _cubit = AddressSearchCubit(dependencies.dio);

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
    if (widget.initialAddress != null) listener();
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
      appBar: CustomAppBar(title: 'Выбери адрес', simplified: true),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: AppTextFormField(labelText: 'Адрес', focusNode: _focusNode, controller: _controller),
          ),
          Expanded(
            child: BlocBuilder<AddressSearchCubit, AddressSearchState>(
              bloc: _cubit,
              builder: (context, state) => switch (state) {
                AddressSearchLoaded(:final data) => SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var address in data)
                          GestureDetector(
                            onTap: () {
                              logger.info('user picked address: ${address.toJson()}');
                              Navigator.pop(context, address);
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
                              ),
                              child: AppText(address.cityAndAddress, style: AppTextStyles.bodyLarge),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                AddressSearchError(:final error) => AppErrorWidget(error: error),
                _ => SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}
