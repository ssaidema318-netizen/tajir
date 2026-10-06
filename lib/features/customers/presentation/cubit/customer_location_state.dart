part of 'customer_location_cubit.dart';

abstract class CustomerLocationState extends Equatable {
  const CustomerLocationState();

  @override
  List<Object?> get props => [];
}

class CustomerLocationInitial extends CustomerLocationState {}

class CustomerLocationLoading extends CustomerLocationState {}

class CustomerLocationSuccess extends CustomerLocationState {
  final double latitude;
  final double longitude;

  const CustomerLocationSuccess({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
      ];
}

class CustomerLocationError extends CustomerLocationState {
  final String message;

  const CustomerLocationError(this.message);

  @override
  List<Object?> get props => [message];
}