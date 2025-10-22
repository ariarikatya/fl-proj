import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

late BlocsProvider blocs;

abstract class BlocsProvider {
  BlocsProvider({required this.factories});

  T get<T extends BlocBase>(BuildContext context) {
    bool created = blocs[T] == null;
    blocs[T] ??= factories[T]?.call(context) ?? (throw Exception('Factory for $T not found'));
    if (created) logger.debug('Created $T');
    return blocs[T] as T;
  }

  bool contains<T extends BlocBase>() => blocs.containsKey(T);

  void destroy<T extends BlocBase>() {
    bool destroyed = blocs[T] != null;
    blocs[T]?.close();
    if (destroyed) logger.debug('Destroyed $T');
    blocs.remove(T);
  }

  void clear() {
    for (var bloc in blocs.values) {
      bloc.close();
    }
    blocs.clear();
  }

  final Map<Type, BlocBase> blocs = {};

  final Map<Type, BlocBase Function(BuildContext context)> factories;
}
