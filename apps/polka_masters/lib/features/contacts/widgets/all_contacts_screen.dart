import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/add_contact_button.dart';
import 'package:polka_masters/features/contacts/widgets/contact_screen.dart';
import 'package:polka_masters/features/contacts/widgets/contact_tile.dart';
import 'package:shared/shared.dart';

class AllContactsScreen extends StatefulWidget {
  const AllContactsScreen({super.key, this.onContactTap});

  final void Function(BuildContext context, Contact contact)? onContactTap;

  @override
  State<AllContactsScreen> createState() => _AllContactsScreenState();
}

class _AllContactsScreenState extends State<AllContactsScreen> with AutomaticKeepAliveClientMixin {
  late final _controller = TextEditingController();
  late final _search = context.read<ContactSearchCubit>();

  @override
  void initState() {
    super.initState();
    _search.bindController(_controller);
  }

  @override
  void dispose() {
    _search.unbindController(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AppPage(
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.ext.colors.white[200],
                  border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
                ),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: AppTextFormField(
                  hintText: 'Имя или номер телефона',
                  compact: true,
                  prefixIcon: FIcons.search.icon(context, color: context.ext.colors.black[500]),
                  controller: _controller,
                ),
              ),
              Expanded(
                child: BlocBuilder<ContactSearchCubit, SearchState<Contact>>(
                  builder: (context, state) => switch (state) {
                    SearchInitial() => const SizedBox.shrink(),
                    SearchLoading() => const Center(child: LoadingIndicator()),
                    SearchLoaded(:final data) =>
                      data.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  AppText(
                                    'К сожалению, такого\nклиента у тебя нет',
                                    style: AppTextStyles.headingSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  AppText.secondary(
                                    'Попробуй изменить запрос\nили добавь новый контакт',
                                    style: AppTextStyles.bodyMedium500,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (ctx, index) {
                                final contact = data[index];
                                return ContactTile(
                                  contact: contact,
                                  onTap: () {
                                    if (widget.onContactTap != null) {
                                      widget.onContactTap!(ctx, contact);
                                    } else {
                                      ctx.ext.push(ContactScreen(contactId: contact.id));
                                    }
                                  },
                                );
                              },
                            ),
                    SearchError(:final error) => AppErrorWidget(error: error),
                  },
                ),
              ),
            ],
          ),
          const Align(alignment: Alignment.bottomCenter, child: AddContactButton()),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
