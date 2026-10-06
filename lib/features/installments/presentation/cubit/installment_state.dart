import 'package:equatable/equatable.dart';

import '../../data/models/installment_plan_model.dart';
import '../../data/models/installment_model.dart';

abstract class InstallmentState extends Equatable {
  const InstallmentState();

  @override
  List<Object?> get props => [];
}

class InstallmentInitial extends InstallmentState {}

class InstallmentLoading extends InstallmentState {}

class InstallmentLoaded extends InstallmentState {
  final List<InstallmentPlanModel> plans;
  final List<InstallmentModel> installments;

  const InstallmentLoaded({
    required this.plans,
    required this.installments,
  });

  @override
  List<Object?> get props => [
        plans,
        installments,
      ];
}

class InstallmentSuccess extends InstallmentState {}

class InstallmentError extends InstallmentState {
  final String message;

  const InstallmentError(this.message);

  @override
  List<Object?> get props => [message];
}