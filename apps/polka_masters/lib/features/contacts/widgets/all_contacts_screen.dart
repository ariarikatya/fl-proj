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

  @override
  void initState() {
    super.initState();
    blocs.get<ContactSearchCubit>(context).bindController(_controller);
  }

  @override
  void dispose() {
    blocs.get<ContactSearchCubit>(context).unbindController(_controller);
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
                  color: context.ext.theme.backgroundSubtle,
                  border: Border(bottom: BorderSide(color: context.ext.theme.backgroundHover)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: AppTextFormField(
                  hintText: 'Имя или номер телефона',
                  compact: true,
                  prefixIcon: AppIcons.search.icon(context, color: context.ext.theme.textPlaceholder),
                  controller: _controller,
                ),
              ),
              Expanded(
                child: BlocBuilder<ContactSearchCubit, SearchState<Contact>>(
                  bloc: blocs.get<ContactSearchCubit>(context),
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
