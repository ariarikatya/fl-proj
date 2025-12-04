import 'package:flutter/material.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/feed/controller/feed_cubit.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final _selectedCategories = List<ServiceCategories>.from(
    context.read<ClientViewModel>().client.preferredServices,
  );
  bool _saving = false;

  void _save() async {
    if (_saving) return;
    _saving = true;
    logger.debug('saving client categories');
    final clientRepo = Dependencies().clientRepository;
    final result = await clientRepo.updatePreferredServices(_selectedCategories.toSet().toList());
    result.when(
      ok: (newCategories) {
        final viewModel = context.read<ClientViewModel>();
        viewModel.updateClient(viewModel.client.copyWith(preferredServices: () => newCategories));
        context.read<FeedCubit>().reset();
        showSuccessSnackbar('Категории успешно обновлены');
        if (mounted) context.ext.pop();
      },
      err: (err, st) => handleError(err, st),
    );
    _saving = false;
    logger.debug('saved client categories');
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Мои категории'),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: AppText('Выбери интересные тебе категории', style: AppTextStyles.headingSmall),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: AppText(
                    'На основе твоего выбора мы показываем мастеров на "Главной"',
                    style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 8),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 8,
                    children: [
                      for (var option in ServiceCategories.categories)
                        AppChip(
                          enabled: _selectedCategories.contains(option),
                          onTap: () => setState(() => _selectedCategories.add(option)),
                          onClose: () => setState(() => _selectedCategories.remove(option)),
                          child: Row(
                            children: [
                              AppEmojis.fromMasterService(option).icon(size: const Size(14, 14)),
                              const SizedBox(width: 4),
                              AppText(option.label, style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: AppTextButton.large(text: 'Сохранить изменения', onTap: _save),
            ),
          ),
        ],
      ),
    );
  }
}
