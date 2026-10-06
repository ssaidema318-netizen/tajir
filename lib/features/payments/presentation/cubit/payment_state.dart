import 'package:equatable/equatable.dart';

import '../../../installments/data/models/installment_model.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;

  const PaymentLoaded({
    required this.payments,
  });

  @override
  List<Object?> get props => [payments];
}

class PaymentSuccess extends PaymentState {
  final PaymentModel payment;
  final InstallmentModel installment;

  const PaymentSuccess({
    required this.payment,
    required this.installment,
  });

  @override
  List<Object?> get props => [
        payment,
        installment,
      ];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}