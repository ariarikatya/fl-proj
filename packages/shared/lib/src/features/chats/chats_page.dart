import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final cubit = blocs.get<ChatsCubit>(context)..loadChats();

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твои чаты'),
      child: BlocBuilder<ChatsCubit, int>(
        bloc: cubit,
        builder: (context, state) {
          if (cubit.loading) {
            return Center(child: LoadingIndicator());
          }

          if (cubit.chats.isEmpty) {
            return Center(child: AppText('Пока у тебя нет чатов'));
          }

          return ListView.builder(
            itemCount: cubit.chats.values.length,
            itemBuilder: (context, index) => ChatWidget(chat: cubit.chats.values.elementAt(index)),
          );
        },
      ),
    );
  }
}
