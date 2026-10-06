import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:tajir/core/services/installment_notification_service.dart';
import 'package:tajir/core/services/notification_service.dart';
import 'package:tajir/features/customers/presentation/cubit/customer_details_cubit.dart';
import 'package:tajir/features/customers/presentation/screens/customer_details_screen.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/hive/hive_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../data/models/customer_model.dart';

import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

import '../../../sales/datasources/sale_local_data_source.dart';
import '../../../sales/models/sale_model.dart';
import '../../../sales/repositories/sale_repository_impl.dart';

import '../../../installments/data/datasources/installment_local_data_source.dart';
import '../../../installments/data/models/installment_model.dart';
import '../../../installments/data/models/installment_plan_model.dart';
import '../../../installments/data/repositories/installment_repository_impl.dart';

import '../../../payments/data/datasources/payment_local_data_source.dart';
import '../../../payments/data/repositories/payment_repository_impl.dart';
import '../../../payments/presentation/cubit/payment_cubit.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> customers) {
    if (_searchQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final name = customer.name.toLowerCase();
      final phone = customer.phone.toLowerCase();
      final idNumber = (customer.idNumber ?? '').toLowerCase();

      return name.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          idNumber.contains(_searchQuery);
    }).toList();
  }

  void _openCustomerDetails(BuildContext context, CustomerModel customer) {
    final salesBox = Hive.box<SaleModel>(AppConstants.salesBox);

    final installmentsBox = Hive.box<InstallmentModel>(
      AppConstants.installmentsBox,
    );

    final plansBox = Hive.box<InstallmentPlanModel>(
      AppConstants.installmentPlansBox,
    );

    final paymentRepository = PaymentRepositoryImpl(
      PaymentLocalDataSource(HiveService.paymentsBox),
    );

    final installmentRepository = InstallmentRepositoryImpl(
      InstallmentLocalDataSource(
        plansBox: plansBox,
        installmentsBox: installmentsBox,
      ),
    );

    final saleRepository = SaleRepositoryImpl(SaleLocalDataSource(salesBox));

    final detailsCubit = CustomerDetailsCubit(
      saleRepository: saleRepository,
      installmentRepository: installmentRepository,
      paymentRepository: paymentRepository,
    );
    final installmentNotificationService = InstallmentNotificationService(
          installmentRepository: installmentRepository,
          notificationService: NotificationService.instance,
          
        );
    final paymentCubit = PaymentCubit(
      paymentRepository: paymentRepository,
      installmentRepository: installmentRepository,
      installmentNotificationService: installmentNotificationService,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<CustomerDetailsCubit>(
              create: (_) => detailsCubit..loadCustomer(customer),
            ),
            BlocProvider<PaymentCubit>(create: (_) => paymentCubit),
          ],
          child: CustomerDetailsScreen(customer: customer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: const Text(
          'العملاء',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return _buildError(context, state.message);
          }

          if (state is CustomerLoaded) {
            final customers = _filterCustomers(state.customers);

            return _buildCustomersContent(
              context,
              customers,
              state.customers.length,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCustomersContent(
    BuildContext context,
    List<CustomerModel> customers,
    int totalCustomers,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CustomerCubit>().loadCustomers();
      },

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100,
        ),

        children: [
          _buildHeader(totalCustomers),

          const SizedBox(height: AppSpacing.md),

          _buildSearchField(),

          const SizedBox(height: AppSpacing.lg),

          if (customers.isEmpty)
            _buildEmptyState(hasSearch: _searchQuery.isNotEmpty)
          else
            ...customers.map(
              (customer) => _buildCustomerCard(context, customer),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalCustomers) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عملاؤك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$totalCustomers عميل مسجل',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$totalCustomers',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,

      textInputAction: TextInputAction.search,

      decoration: InputDecoration(
        hintText: 'ابحث بالاسم أو رقم الهاتف أو الرقم القومي',

        prefixIcon: const Icon(Icons.search),

        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : null,

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel customer) {
    final hasImage =
        customer.customerImagePath != null &&
        customer.customerImagePath!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: () {
            _openCustomerDetails(context, customer);
          },

          borderRadius: BorderRadius.circular(18),

          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),

            child: Row(
              children: [
                _buildAvatar(customer, hasImage),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              customer.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (customer.address != null &&
                          customer.address!.trim().isNotEmpty) ...[
                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                customer.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(CustomerModel customer, bool hasImage) {
    return Container(
      width: 54,
      height: 54,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: AppColors.primary.withValues(alpha: 0.10),

        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),

      child: ClipOval(
        child: hasImage
            ? Image.asset(
                customer.customerImagePath!,
                fit: BoxFit.cover,

                errorBuilder: (_, _, _) {
                  return _defaultAvatar();
                },
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return const Icon(Icons.person_outline, color: AppColors.primary, size: 27);
  }

  Widget _buildEmptyState({required bool hasSearch}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),

            child: Icon(
              hasSearch ? Icons.search_off_outlined : Icons.people_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            hasSearch ? 'لا توجد نتائج' : 'لا يوجد عملاء بعد',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            hasSearch
                ? 'جرّب البحث باسم مختلف أو رقم هاتف آخر'
                : 'سيظهر العملاء هنا بعد تسجيل أول عملية بيع',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),

            const SizedBox(height: AppSpacing.md),

            const Text(
              'حدث خطأ أثناء تحميل العملاء',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            FilledButton.icon(
              onPressed: () {
                context.read<CustomerCubit>().loadCustomers();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
