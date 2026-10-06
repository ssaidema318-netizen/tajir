import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:tajir/core/constants/app_constants.dart';
import 'package:tajir/core/database/hive/hive_service.dart';
import 'package:tajir/core/services/customer_deletion_service.dart';
import 'package:tajir/core/services/installment_notification_service.dart';
import 'package:tajir/core/services/notification_service.dart';

import 'package:tajir/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';
import 'package:tajir/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:tajir/features/customers/presentation/cubit/customer_cubit.dart';
import 'package:tajir/features/customers/presentation/cubit/customer_location_cubit.dart';
import 'package:tajir/features/customers/presentation/screens/customers_screen.dart';

import 'package:tajir/features/dashboard/presentation/screens/dashboard_screen.dart';

import 'package:tajir/features/installments/data/datasources/installment_local_data_source.dart';
import 'package:tajir/features/installments/data/models/installment_model.dart';
import 'package:tajir/features/installments/data/models/installment_plan_model.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';

import 'package:tajir/features/payments/data/datasources/payment_local_data_source.dart';
import 'package:tajir/features/payments/data/models/payment_model.dart';
import 'package:tajir/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:tajir/features/payments/presentation/cubit/payment_filter.dart';
import 'package:tajir/features/payments/presentation/screens/payments_screen.dart';

import 'package:tajir/features/sales/datasources/sale_local_data_source.dart';
import 'package:tajir/features/sales/models/sale_model.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_cubit.dart';
import 'package:tajir/features/sales/presentation/screens/create_sale_screen.dart';
import 'package:tajir/features/sales/repositories/sale_repository_impl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  PaymentFilter paymentFilter = PaymentFilter.all;

  final GlobalKey<DashboardScreenState> dashboardKey =
      GlobalKey<DashboardScreenState>();

  @override
  Widget build(BuildContext context) {
    // =====================================================
    // Customer Location Repository
    // =====================================================

    final customersBox = Hive.box<CustomerModel>(AppConstants.customersBox);

    final customerLocalDataSource = CustomerLocalDataSource(
      customersBox: customersBox,
    );

    final customerRepository = CustomerRepositoryImpl(
      localDataSource: customerLocalDataSource,
    );

    return BlocProvider<CustomerLocationCubit>(
      create: (_) {
        return CustomerLocationCubit(customerRepository: customerRepository);
      },
      child: _buildMainScaffold(),
    );
  }

  Widget _buildMainScaffold() {
    final pages = [
      // =====================================================
      // Dashboard
      // =====================================================
      DashboardScreen(
        key: dashboardKey,
        onAddSale: () {
          setState(() {
            currentIndex = 2;
          });
        },
        onOpenCustomers: () {
          setState(() {
            currentIndex = 1;
          });
        },
        onOpenPayments: () {
          setState(() {
            paymentFilter = PaymentFilter.all;
            currentIndex = 3;
          });
        },
        onOpenPaymentsWithFilter: (filter) {
          setState(() {
            paymentFilter = filter;
            currentIndex = 3;
          });
        },
      ),

      // =====================================================
      // Customers
      // =====================================================
      MultiBlocProvider(
        providers: [
          BlocProvider<CustomerCubit>(
            create: (_) {
              final customersBox = Hive.box<CustomerModel>(
                AppConstants.customersBox,
              );
              final salesBox = Hive.box<SaleModel>(AppConstants.salesBox);
              final plansBox = Hive.box<InstallmentPlanModel>(
                AppConstants.installmentPlansBox,
              );
              final installmentsBox = Hive.box<InstallmentModel>(
                AppConstants.installmentsBox,
              );
              final paymentsBox = Hive.box<PaymentModel>(
                AppConstants.paymentsBox,
              );
              final customerLocalDataSource = CustomerLocalDataSource(
                customersBox: customersBox,
              );
              final salelocalDataSource = SaleLocalDataSource(salesBox);
              final installmentLocalDataSource = InstallmentLocalDataSource(
                plansBox: plansBox,
                installmentsBox: installmentsBox,
              );
              final paymentLocalDataSource = PaymentLocalDataSource(
                paymentsBox,
              );
              final repository = CustomerRepositoryImpl(
                localDataSource: customerLocalDataSource,
              );
              final saleRepository = SaleRepositoryImpl(salelocalDataSource);
              final installmentRepository = InstallmentRepositoryImpl(
                installmentLocalDataSource,
              );
              final paymentRepository = PaymentRepositoryImpl(
                paymentLocalDataSource,
              );
              final notificationService = NotificationService.instance;
              final installmentNotificationService = InstallmentNotificationService(
                installmentRepository: installmentRepository,
                notificationService: notificationService,
              );
              final deleteCustomerCascadeUseCase = CustomerDeletionService(
                customerRepository: repository,
                saleRepository: saleRepository,
                installmentRepository: installmentRepository,
                paymentRepository: paymentRepository,
                installmentNotificationService: installmentNotificationService,
              );
              final cubit = CustomerCubit(
                 repository: repository, deletionService: deleteCustomerCascadeUseCase,
                
              );

              cubit.loadCustomers();

              return cubit;
            },
          ),
        ],
        child: const CustomersScreen(),
      ),

      // =====================================================
      // Create Sale
      // =====================================================
      BlocProvider(
        create: (_) {
          final customersBox = Hive.box<CustomerModel>(
            AppConstants.customersBox,
          );

          final salesBox = Hive.box<SaleModel>(AppConstants.salesBox);

          final installmentsBox = Hive.box<InstallmentModel>(
            AppConstants.installmentsBox,
          );

          final plansBox = Hive.box<InstallmentPlanModel>(
            AppConstants.installmentPlansBox,
          );

          final customerLocalDataSource = CustomerLocalDataSource(
            customersBox: customersBox,
          );

          final customerRepository = CustomerRepositoryImpl(
            localDataSource: customerLocalDataSource,
          );

          final saleRepository = SaleRepositoryImpl(
            SaleLocalDataSource(salesBox),
          );

          final installmentRepository = InstallmentRepositoryImpl(
            InstallmentLocalDataSource(
              plansBox: plansBox,
              installmentsBox: installmentsBox,
            ),
          );

          final paymentRepository = PaymentRepositoryImpl(
            PaymentLocalDataSource(HiveService.paymentsBox),
          );

          return CreateSaleCubit(
            customerRepository: customerRepository,
            saleRepository: saleRepository,
            installmentRepository: installmentRepository,
            paymentRepository: paymentRepository,
          );
        },
        child: CreateSaleScreen(
          onSaleSaved: () {
            dashboardKey.currentState?.refreshDashboard();
          },
        ),
      ),

      // =====================================================
      // Payments
      // =====================================================
      PaymentsScreen(
        key: ValueKey(paymentFilter),
        filter: paymentFilter,
        onClearFilter: () {
          setState(() {
            paymentFilter = PaymentFilter.all;
          });
        },
        onPaymentSaved: () {
          dashboardKey.currentState?.refreshDashboard();
        },
      ),

      // =====================================================
      // More
      // =====================================================
      const Center(child: Text('More')),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;

            if (index == 3) {
              paymentFilter = PaymentFilter.all;
            }
          });

          // ==========================
          // Refresh Dashboard
          // ==========================

          if (index == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              dashboardKey.currentState?.refreshDashboard();
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'العملاء',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'المبيعات',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'التحصيل',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}
