import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tajir/features/sales/models/sale_item_model.dart';
import 'package:tajir/features/sales/models/sale_model.dart';
import 'package:tajir/features/sales/repositories/sale_repository_impl.dart';

import '../../../../core/utils/id_generator.dart';

import '../../../customers/data/models/customer_model.dart';
import '../../../customers/data/repositories/customer_repository_impl.dart';

import '../../../installments/data/models/installment_model.dart';
import '../../../installments/data/models/installment_plan_model.dart';
import '../../../installments/data/repositories/installment_repository_impl.dart';

import '../../../payments/data/models/payment_model.dart';
import '../../../payments/data/repositories/payment_repository_impl.dart';

import 'create_sale_state.dart';

class PreparedSale {
  final SaleModel sale;
  final CustomerModel? newCustomer;

  const PreparedSale({
    required this.sale,
    this.newCustomer,
  });
}

class CreateSaleCubit extends Cubit<CreateSaleState> {
  final CustomerRepositoryImpl customerRepository;
  final SaleRepositoryImpl saleRepository;
  final InstallmentRepositoryImpl installmentRepository;
  final PaymentRepositoryImpl paymentRepository;

  CreateSaleCubit({
    required this.customerRepository,
    required this.saleRepository,
    required this.installmentRepository,
    required this.paymentRepository,
  }) : super(CreateSaleInitial());

  void initialize() {
    try {
      final customers = customerRepository.getCustomers();

      emit(
        CreateSaleLoaded(
          customers: customers,
        ),
      );
    } catch (e) {
      emit(
        CreateSaleError(
          e.toString(),
        ),
      );
    }
  }

  void selectCustomer(CustomerModel customer) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    emit(
      currentState.copyWith(
        selectedCustomer: customer,
      ),
    );
  }

  void clearCustomer() {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    emit(
      currentState.copyWith(
        clearCustomer: true,
      ),
    );
  }

  void updateCustomerDraft({
    String? name,
    String? phone,
    String? address,
    String? idNumber,
    String? idImagePath,
    String? customerImagePath,
    double? latitude,
    double? longitude,
  }) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    final currentDraft = currentState.customerDraft;

    emit(
      currentState.copyWith(
        customerDraft: currentDraft.copyWith(
          name: name,
          phone: phone,
          address: address,
          idNumber: idNumber,
          idImagePath: idImagePath,
          customerImagePath: customerImagePath,
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  void addItem({
    required String productName,
    required int quantity,
    required int unitPrice,
  }) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    if (productName.trim().isEmpty) return;
    if (quantity <= 0) return;
    if (unitPrice <= 0) return;

    final item = CreateSaleItem(
      productName: productName.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
    );

    emit(
      currentState.copyWith(
        selectedItems: [
          ...currentState.selectedItems,
          item,
        ],
      ),
    );
  }

  void updateItem(
    int index, {
    String? productName,
    int? quantity,
    int? unitPrice,
  }) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    if (index < 0 ||
        index >= currentState.selectedItems.length) {
      return;
    }

    final items = [
      ...currentState.selectedItems,
    ];

    items[index] = items[index].copyWith(
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
    );

    emit(
      currentState.copyWith(
        selectedItems: items,
      ),
    );
  }

  void removeItem(int index) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    if (index < 0 ||
        index >= currentState.selectedItems.length) {
      return;
    }

    final items = [
      ...currentState.selectedItems,
    ];

    items.removeAt(index);

    emit(
      currentState.copyWith(
        selectedItems: items,
      ),
    );
  }

  void setDiscount(int discount) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    if (discount < 0) {
      discount = 0;
    }

    emit(
      currentState.copyWith(
        discount: discount,
      ),
    );
  }

  void setDownPayment(int amount) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    if (amount < 0) {
      amount = 0;
    }

    if (amount > currentState.totalAmount) {
      amount = currentState.totalAmount;
    }

    emit(
      currentState.copyWith(
        downPayment: amount,
      ),
    );
  }

  void setDownPaymentMethod(String method) {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) return;

    emit(
      currentState.copyWith(
        downPaymentMethod: method,
      ),
    );
  }

  PreparedSale? prepareSale() {
    final currentState = state;

    if (currentState is! CreateSaleLoaded) {
      return null;
    }

    CustomerModel? customer =
        currentState.selectedCustomer;

    // إنشاء عميل جديد إذا لم يتم اختيار عميل موجود
    if (customer == null) {
      final draft = currentState.customerDraft;

      if (draft.name.trim().isEmpty) {
        emit(
          const CreateSaleError(
            'يجب إدخال اسم العميل',
          ),
        );
        return null;
      }

      if (draft.phone.trim().isEmpty) {
        emit(
          const CreateSaleError(
            'يجب إدخال رقم الهاتف',
          ),
        );
        return null;
      }

      customer = CustomerModel(
        id: IdGenerator.generate(),
        name: draft.name.trim(),
        phone: draft.phone.trim(),
        address: draft.address?.trim().isEmpty == true
            ? null
            : draft.address?.trim(),
        idNumber: draft.idNumber?.trim().isEmpty == true
            ? null
            : draft.idNumber?.trim(),
        idImagePath: draft.idImagePath,
        customerImagePath: draft.customerImagePath,
        createdAt: DateTime.now(),
        latitude: draft.latitude,
        longitude: draft.longitude,
      );
    }

    if (currentState.selectedItems.isEmpty) {
      emit(
        const CreateSaleError(
          'يجب إضافة منتج واحد على الأقل',
        ),
      );
      return null;
    }

    if (currentState.downPayment >
        currentState.totalAmount) {
      emit(
        const CreateSaleError(
          'المقدم لا يمكن أن يكون أكبر من إجمالي العملية',
        ),
      );
      return null;
    }

    final sale = SaleModel(
      id: IdGenerator.generate(),
      customerId: customer.id,
      items: currentState.selectedItems.map((item) {
        return SaleItemModel(
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          total: item.total,
        );
      }).toList(),
      subtotal: currentState.subtotal,
      discount: currentState.discount,
      totalAmount: currentState.totalAmount,
      downPayment: currentState.downPayment,
      financedAmount: currentState.financedAmount,
      saleDate: DateTime.now(),
      downPaymentMethod:
          currentState.downPaymentMethod,
    );

    final isNewCustomer =
        currentState.selectedCustomer == null;

    return PreparedSale(
      sale: sale,
      newCustomer:
          isNewCustomer ? customer : null,
    );
  }

  Future<void> saveSaleWithInstallments({
    required SaleModel sale,
    CustomerModel? newCustomer,
    required String frequency,
    required List<int> amounts,
    required List<DateTime> dueDates,
  }) async {
    try {
      // -----------------------------
      // Validation
      // -----------------------------

      if (amounts.isEmpty) {
        emit(
          const CreateSaleError(
            'يجب إضافة قسط واحد على الأقل',
          ),
        );
        return;
      }

      if (amounts.length != dueDates.length) {
        emit(
          const CreateSaleError(
            'عدد الأقساط لا يطابق عدد المواعيد',
          ),
        );
        return;
      }

      final installmentsTotal = amounts.fold<int>(
        0,
        (sum, amount) => sum + amount,
      );

      if (installmentsTotal != sale.financedAmount) {
        emit(
          CreateSaleError(
            'مجموع الأقساط ($installmentsTotal) '
            'لا يساوي المبلغ المتبقي '
            '(${sale.financedAmount})',
          ),
        );
        return;
      }

      // -----------------------------
      // Saving state
      // -----------------------------

      final currentState = state;

      emit(
        CreateSaleSaving(
          currentState is CreateSaleLoaded
              ? currentState
              : CreateSaleLoaded(
                  customers:
                      customerRepository.getCustomers(),
                ),
        ),
      );

      // -----------------------------
      // Create installment plan
      // -----------------------------

      final planId = IdGenerator.generate();

      final plan = InstallmentPlanModel(
        id: planId,
        customerId: sale.customerId,
        saleId: sale.id,
        frequency: frequency,
        totalAmount: sale.financedAmount,
        numberOfInstallments: amounts.length,
        createdAt: DateTime.now(),
      );

      // -----------------------------
      // Save new customer
      // -----------------------------

      if (newCustomer != null) {
        await customerRepository.addCustomer(
          newCustomer,
        );
      }

      // -----------------------------
      // Save sale
      // -----------------------------

      await saleRepository.addSale(sale);

      // -----------------------------
      // Save down payment
      // -----------------------------

      if (sale.downPayment > 0) {
        final downPayment = PaymentModel(
          id: IdGenerator.generate(),
          customerId: sale.customerId,
          saleId: sale.id,

          // المقدم ليس تابعًا لأي قسط
          installmentId: null,

          amount: sale.downPayment,
          paymentMethod: sale.downPaymentMethod,
          paidAt: sale.saleDate,
        );

        await paymentRepository.addPayment(
          downPayment,
        );
      }

      // -----------------------------
      // Save installment plan
      // -----------------------------

      await installmentRepository.addPlan(
        plan,
      );

      // -----------------------------
      // Save installments
      // -----------------------------

      for (int i = 0; i < amounts.length; i++) {
        final installment = InstallmentModel(
          id: IdGenerator.generate(),
          planId: planId,
          customerId: sale.customerId,
          saleId: sale.id,
          installmentNumber: i + 1,
          dueAmount: amounts[i],
          paidAmount: 0,
          dueDate: dueDates[i],
          status: 'pending',
        );

        await installmentRepository.addInstallment(
          installment,
        );
      }

      // -----------------------------
      // Success
      // -----------------------------

      emit(
        CreateSaleSuccess(),
      );
    } catch (e) {
      emit(
        CreateSaleError(
          e.toString(),
        ),
      );
    }
  }
}
