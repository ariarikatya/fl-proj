import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, this.initFilter, this.showSorting = true});

  final SearchFilter? initFilter;
  final bool showSorting;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late var filter = widget.initFilter ?? const SearchFilter();
  late final _now = DateTime.now();
  late final _minPriceController = TextEditingController(text: filter.price?.min?.toString());
  late final _maxPriceController = TextEditingController(text: filter.price?.max?.toString());

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  late final _dateRanges = [
    ('Есть сегодня', DateTimeRange(start: _now, end: _now.add(const Duration(days: 1)))),
    ('Есть в течение 3 дней', DateTimeRange(start: _now, end: _now.add(const Duration(days: 3)))),
  ];

  void _clear() => setState(() => filter = const SearchFilter());
  void _updateFilter(SearchFilter Function() update) => setState(() => filter = update());

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const ModalAppBar(title: 'Фильтры'),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: AppText(
                      'Настрой под себя',
                      style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _subtitle('Категории'),
                  _optionsWrapper(
                    ServiceCategories.categories,
                    (category) => AppChip(
                      enabled: filter.categories.contains(category),
                      onTap: () =>
                          _updateFilter(() => filter.copyWith(categories: () => {...filter.categories, category})),
                      onClose: () => _updateFilter(
                        () => filter.copyWith(categories: () => {...filter.categories}..remove(category)),
                      ),
                      child: Row(
                        children: [
                          AppEmojis.fromMasterService(category).icon(size: const Size(14, 14)),
                          const SizedBox(width: 4),
                          AppText(category.label, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  _subtitle('Дата записи'),
                  _optionsWrapper(
                    _dateRanges,
                    (dateRange) => AppChip(
                      enabled: filter.dateRange?.toJson() == dateRange.$2.toJson(),
                      onTap: () => _updateFilter(() => filter.copyWith(dateRange: () => dateRange.$2)),
                      onClose: () => _updateFilter(() => filter.copyWith(dateRange: () => null)),
                      child: AppText(dateRange.$1, style: AppTextStyles.bodyMedium),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: AppTextButtonSecondary.large(
                      text: filter.dateRange == null ? 'Выбрать дату' : filter.dateRange!.formatDMY(),
                      onTap: () async {
                        final dateRange = await DateTimePickerMBS.pickDateRange(context, initValue: filter.dateRange);
                        if (dateRange != null) {
                          _updateFilter(() => filter.copyWith(dateRange: () => dateRange));
                        }
                      },
                    ),
                  ),
                  _subtitle('Цена'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: AppTextFormField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: AppText(
                                'от',
                                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textPlaceholder),
                              ),
                            ),
                            onClear: () {
                              _updateFilter(() => filter.copyWith(price: () => (min: null, max: filter.price?.max)));
                            },
                            onFieldSubmitted: (value) {
                              _updateFilter(
                                () => filter.copyWith(price: () => (min: int.tryParse(value), max: filter.price?.max)),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: AppTextFormField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: AppText(
                                'до',
                                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textPlaceholder),
                              ),
                            ),
                            onClear: () {
                              _updateFilter(() => filter.copyWith(price: () => (min: filter.price?.min, max: null)));
                            },
                            onFieldSubmitted: (value) {
                              _updateFilter(
                                () => filter.copyWith(price: () => (min: filter.price?.min, max: int.tryParse(value))),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  _subtitle('Локация'),
                  _optionsWrapper(
                    ServiceLocation.values,
                    (location) => AppChip(
                      enabled: filter.location == location,
                      onTap: () => _updateFilter(() => filter.copyWith(location: () => location)),
                      onClose: () => _updateFilter(() => filter.copyWith(location: () => null)),
                      child: AppText(location.label, style: AppTextStyles.bodyMedium),
                    ),
                  ),
                  if (widget.showSorting) ...[
                    _subtitle('Сортировка'),
                    _optionsWrapper(
                      SearchSort.values,
                      (sort) => AppChip(
                        enabled: filter.sort == sort,
                        onTap: () => _updateFilter(() => filter.copyWith(sort: () => sort)),
                        onClose: () => _updateFilter(() => filter.copyWith(sort: () => null)),
                        child: AppText(sort.label, style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  ],
                  _ClearButton(_clear),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: AppTextButton.large(
              text: 'Применить фильтры${filter.hasActiveFilters ? ' (${filter.activeFiltersCount})' : ''}',
              onTap: () {
                logger.info("Фильтры применены: ${filter.toJson()}");
                Navigator.of(context).pop(filter);
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _subtitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: AppText(text, style: AppTextStyles.bodyLarge),
    );
  }

  Widget _optionsWrapper<T>(List<T> options, AppChip Function(T) child) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Wrap(spacing: 4, runSpacing: 8, children: [for (var option in options) child(option)]),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton(this.onTap);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 16, color: context.ext.theme.textPrimary),
                const SizedBox(width: 4),
                AppText('Очистить все', style: AppTextStyles.bodyMedium.copyWith(decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
