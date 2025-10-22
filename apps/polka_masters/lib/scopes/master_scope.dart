import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MasterData extends Equatable {
  const MasterData({
    required this.schedule,
    required this.phoneNumber,
    required this.tokens,
    required this.master,
    required void Function(Master master) onMasterUpdate,
  }) : _onMasterUpdate = onMasterUpdate;

  final Master master;
  final Schedule schedule;
  final String phoneNumber;
  final TokensPair tokens;

  final void Function(Master master) _onMasterUpdate;

  void updateMaster(Master Function(Master master) fn) => _onMasterUpdate(fn(master));

  @override
  List<Object?> get props => [schedule, phoneNumber, tokens, master];
}

class MasterScope extends InheritedWidget {
  const MasterScope({super.key, required this.masterData, required super.child});

  final MasterData masterData;

  static MasterData of(BuildContext context, {bool listen = true}) => MasterScope.maybeOf(context, listen: listen)!;

  static MasterData? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<MasterScope>()?.masterData;
    }
    return context.getInheritedWidgetOfExactType<MasterScope>()?.masterData;
  }

  @override
  bool updateShouldNotify(MasterScope oldWidget) => masterData != oldWidget.masterData;
}
