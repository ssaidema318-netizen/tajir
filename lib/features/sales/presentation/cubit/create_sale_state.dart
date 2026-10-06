import 'package:equatable/equatable.dart';

import '../../../customers/data/models/customer_model.dart';

class CreateSaleItem extends Equatable {
  final String productName;
  final int quantity;
  final int unitPrice;

  const CreateSaleItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  int get total => quantity * unitPrice;

  CreateSaleItem copyWith({
    String? productName,
    int? quantity,
    int? unitPrice,
  }) {
    return CreateSaleItem(
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [
        productName,
        quantity,
        unitPrice,
      ];
}

class CustomerDraft extends Equatable {
  final String name;
  final String phone;
  final String? address;
  final String? idNumber;
  final String? idImagePath;
  final String? customerImagePath;
  final double? latitude;
  final double? longitude;

  const CustomerDraft({
    this.name = '',
    this.phone = '',
    this.address,
    this.idNumber,
    this.idImagePath,
    this.customerImagePath,
    this.latitude,
    this.longitude,
  });

  CustomerDraft copyWith({
    String? name,
    String? phone,
    String? address,
    String? idNumber,
    String? idImagePath,
    String? customerImagePath,
    double? latitude,
    double? longitude,
  }) {
    return CustomerDraft(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      idNumber: idNumber ?? this.idNumber,
      idImagePath: idImagePath ?? this.idImagePath,
      customerImagePath:
          customerImagePath ?? this.customerImagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        name,
        phone,
        address,
        idNumber,
        idImagePath,
        customerImagePath,
        latitude,
        longitude,
      ];
}

abstract class CreateSaleState extends Equatable {
  const CreateSaleState();

  @override
  List<Object?> get props => [];
}

class CreateSaleInitial extends CreateSaleState {}

class CreateSaleLoaded extends CreateSaleState {
  final List<CustomerModel> customers;

  final CustomerModel? selectedCustomer;

  final CustomerDraft customerDraft;

  final List<CreateSaleItem> selectedItems;

  final int discount;

  final int downPayment;

  // طريقة دفع المقدم
  final String downPaymentMethod;

  const CreateSaleLoaded({
    required this.customers,
    this.selectedCustomer,
    this.customerDraft = const CustomerDraft(),
    this.selectedItems = const [],
    this.discount = 0,
    this.downPayment = 0,
    this.downPaymentMethod = 'cash',
  });

  int get subtotal {
    return selectedItems.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }

  int get totalAmount {
    final total = subtotal - discount;

    return total < 0 ? 0 : total;
  }

  int get financedAmount {
    final remaining = totalAmount - downPayment;

    return remaining < 0 ? 0 : remaining;
  }

  CreateSaleLoaded copyWith({
    List<CustomerModel>? customers,
    CustomerModel? selectedCustomer,
    bool clearCustomer = false,
    CustomerDraft? customerDraft,
    List<CreateSaleItem>? selectedItems,
    int? discount,
    int? downPayment,
    String? downPaymentMethod,
  }) {
    return CreateSaleLoaded(
      customers: customers ?? this.customers,
      selectedCustomer: clearCustomer
          ? null
          : selectedCustomer ?? this.selectedCustomer,
      customerDraft: customerDraft ?? this.customerDraft,
      selectedItems: selectedItems ?? this.selectedItems,
      discount: discount ?? this.discount,
      downPayment: downPayment ?? this.downPayment,
      downPaymentMethod:
          downPaymentMethod ?? this.downPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        customers,
        selectedCustomer,
        customerDraft,
        selectedItems,
        discount,
        downPayment,
        downPaymentMethod,
      ];
}

class CreateSaleSaving extends CreateSaleState {
  final CreateSaleLoaded data;

  const CreateSaleSaving(this.data);

  @override
  List<Object?> get props => [data];
}

class CreateSaleSuccess extends CreateSaleState {}

class CreateSaleError extends CreateSaleState {
  final String message;

  const CreateSaleError(this.message);

  @override
  List<Object?> get props => [message];
}
