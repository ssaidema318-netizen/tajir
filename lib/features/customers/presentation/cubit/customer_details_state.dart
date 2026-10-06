part of 'customer_details_cubit.dart';

abstract class CustomerDetailsState extends Equatable {
  const CustomerDetailsState();
  @override
  List<Object?> get props => [];
}

class CustomerDetailsInitial extends CustomerDetailsState {}

class CustomerDetailsLoading extends CustomerDetailsState {}

class CustomerDetailsLoaded extends CustomerDetailsState {
  final CustomerModel customer;
  final List<SaleModel> sales;
  final List<InstallmentModel> installments;
  final List<PaymentModel> payments;
  final int totalPurchases;
  final int totalPaid;
  final int totalRemaining;
  final List<InstallmentModel> overdueInstallments;
  final List<InstallmentModel> upcomingInstallments;
  const CustomerDetailsLoaded({
    required this.customer,
    required this.sales,
    required this.installments,
    required this.payments,
    required this.totalPurchases,
    required this.totalPaid,
    required this.totalRemaining,
    required this.overdueInstallments,
    required this.upcomingInstallments,
  });
  @override
  List<Object?> get props => [
    customer,
    sales,
    installments,
    payments,
    totalPurchases,
    totalPaid,
    totalRemaining,
    overdueInstallments,
    upcomingInstallments,
  ];
}

class CustomerDetailsError extends CustomerDetailsState {
  final String message;
  const CustomerDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}
