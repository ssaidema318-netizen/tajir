import 'package:equatable/equatable.dart';
import 'package:tajir/features/sales/models/sale_model.dart';


abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {}

class SaleLoading extends SaleState {}

class SaleLoaded extends SaleState {
  final List<SaleModel> sales;

  const SaleLoaded(this.sales);

  @override
  List<Object?> get props => [sales];
}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}