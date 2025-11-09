import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/all_contacts_screen.dart';
import 'package:polka_masters/features/contacts/widgets/contact_tile.dart';
import 'package:polka_masters/features/contacts/widgets/snackbars.dart';
import 'package:shared/shared.dart';

class PickContactScreenAlt extends StatelessWidget {
  const PickContactScreenAlt({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твои клиенты'),
      child: AllContactsScreen(onContactTap: (ctx, contact) => ctx.ext.pop(contact)),
    );
  }
}

class PickContactScreen extends StatefulWidget {
  const PickContactScreen({super.key, this.contact});

  final Contact? contact;

  @override
  State<PickContactScreen> createState() => _PickContactScreenState();
}

class _PickContactScreenState extends State<PickContactScreen> {
  late final _focusNode = FocusNode()..addListener(_onFocusChange);
  late final _controller = TextEditingController()..addListener(_onQueryChange);
  late final _search = ContactSearchCubit(Dependencies().contactsRepo);

  late Contact? _selectedContact = widget.contact;

  bool _focused = false;
  String? _query;

  bool get searching => _focused || _query != null;

  void _onQueryChange() => setState(() => _query = _controller.text.isNotEmpty ? _controller.text : null);
  void _onFocusChange() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _focused = _focusNode.hasFocus));

  @override
  void initState() {
    super.initState();
    _search.bindController(_controller);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _search.close();
    super.dispose();
  }

  void _pickContact(Contact contact) => context.ext.pop(contact);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Выбери контакт'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Добавь клиента', style: AppTextStyles.headingLarge),
                const SizedBox(height: 8),
                AppText.secondary(
                  'Начни вводить имя клиента и выбери из списка, если клиент из POLKA или уже был добавлен',
                  style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
                ),
                const SizedBox(height: 24),
                AppTextFormField(
                  hintText: 'Выбери клиента',
                  prefixIcon: AppIcons.search.icon(context, color: context.ext.theme.textPlaceholder),
                  controller: _controller,
                  focusNode: _focusNode,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          Divider(color: context.ext.theme.backgroundHover, height: 1),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (searching) ...[
                    BlocBuilder<ContactSearchCubit, SearchState<Contact>>(
                      bloc: _search,
                      builder: (context, state) => switch (state) {
                        SearchInitial() => const SizedBox.shrink(),
                        SearchLoading() => const Center(child: LoadingIndicator()),
                        SearchLoaded(:final data) =>
                          data.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        'К сожалению, такого клиента у тебя нет',
                                        style: AppTextStyles.headingSmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      AppText.secondary(
                                        'Попробуй изменить запрос или добавь новый контакт',
                                        style: AppTextStyles.bodyMedium500,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    final contact = data[index];
                                    return ContactTile(contact: contact, onTap: () => _pickContact(contact));
                                  },
                                ),
                        SearchError(:final error) => AppErrorWidget(error: error),
                      },
                    ),
                  ] else ...[
                    if (_selectedContact != null) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: AppText.secondary('Выбранный контакт'),
                      ),
                      ContactTile(
                        contact: _selectedContact!,
                        onTap: () => _pickContact(_selectedContact!),
                        button: GestureDetector(
                          onTap: () => setState(() => _selectedContact = null),
                          child: Padding(padding: const EdgeInsets.fromLTRB(8, 8, 0, 8), child: AppIcons.close.icon(context)),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        child: _CreateContactView(onCreated: (contact) => setState(() => _selectedContact = contact)),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateContactView extends StatefulWidget {
  const _CreateContactView({required this.onCreated});

  final void Function(Contact contact) onCreated;

  @override
  State<_CreateContactView> createState() => __CreateContactViewState();
}

class __CreateContactViewState extends State<_CreateContactView> {
  late final _nameController = TextEditingController()..addListener(_upd);
  late final _phoneNotifier = ValueNotifier<String>('')..addListener(_upd);
  late final _btnNotifier = ValueNotifier<bool>(false);
  bool _loading = false;

  void _upd() =>
      _btnNotifier.value = _nameController.text.trim().isNotEmpty && _phoneNotifier.value.length == 10 && !_loading;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNotifier.dispose();
    _btnNotifier.dispose();
    super.dispose();
  }

  void _create() async {
    _loading = true;
    _upd(); // Update button state

    final name = _nameController.text.trim();
    final phone = '+7${_phoneNotifier.value}';
    final result = await Dependencies().contactsRepo.createContact(Contact(id: -1, name: name, number: phone));
    result.when(
      ok: (contact) {
        widget.onCreated(contact);
        showSnackbar(contactAddedSnackbar(context, contact));
      },
      err: handleError,
    );

    _loading = false;
    _upd(); // Update button state
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Создай новый контакт', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        AppText.secondary(
          'Заполни данные и добавь клиента в свою записную книгу',
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
        ),
        const SizedBox(height: 24),
        AppTextFormField(hintText: 'Имя клиента', controller: _nameController),
        const SizedBox(height: 8),
        AppPhoneTextField(notifier: _phoneNotifier),
        const SizedBox(height: 16),
        ValueListenableBuilder(
          valueListenable: _btnNotifier,
          builder: (context, enabled, child) {
            return AppTextButton.large(enabled: enabled, text: 'Создать контакт', onTap: _create);
          },
        ),
      ],
    );
  }
}
