import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/src/features/pagination/data_cubit.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';
import 'package:shared/src/widgets/loading/loading_indicator.dart';

class DataBuilder<C extends DataCubit<T>, T extends Object> extends StatelessWidget {
  const DataBuilder({super.key, required this.cubit, required this.dataBuilder});

  final C cubit;
  final Widget Function(BuildContext context, T data) dataBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, DataState<T>>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        DataInitial() => SizedBox.shrink(),
        DataLoading() => _buildLoading(),
        DataLoaded(:final data) => dataBuilder(context, data),
        DataError(:final error) => _buildError(error),
      },
    );
  }

  Widget _buildLoading() => Center(
    child: Padding(padding: EdgeInsets.all(16), child: LoadingIndicator()),
  );

  Widget _buildError(String error) => Center(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AppText('Что-то пошло не так'),
          AppTextButton.small(text: 'Попробовать снова', onTap: () => cubit.load()),
        ],
      ),
    ),
  );
}
