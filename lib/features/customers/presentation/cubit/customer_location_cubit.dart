import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tajir/core/services/map_service.dart';

import 'package:tajir/features/customers/data/repositories/customer_repository_impl.dart';

part 'customer_location_state.dart';

class CustomerLocationCubit extends Cubit<CustomerLocationState> {
  final CustomerRepositoryImpl customerRepository;

  CustomerLocationCubit({
    required this.customerRepository,
  }) : super(CustomerLocationInitial());
  Future<void> openCustomerLocation(String customerId) async {
  try {
    final customer = customerRepository.getCustomer(customerId);

    if (customer == null) {
      emit(
        const CustomerLocationError(
          'العميل غير موجود',
        ),
      );
      return;
    }

    if (customer.latitude == null ||
        customer.longitude == null) {
      emit(
        const CustomerLocationError(
          'لم يتم حفظ موقع العميل بعد',
        ),
      );
      return;
    }

    await MapService.openLocation(
      latitude: customer.latitude!,
      longitude: customer.longitude!,
    );
  } catch (e) {
    emit(
      CustomerLocationError(
        e.toString(),
      ),
    );
  }
}
  Future<void> getAndSaveLocation(String customerId) async {
    try {
      emit(CustomerLocationLoading());

      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        emit(
          const CustomerLocationError(
            'خدمة الموقع غير مفعلة على الجهاز',
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        emit(
          const CustomerLocationError(
            'تم رفض صلاحية الوصول إلى الموقع',
          ),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          const CustomerLocationError(
            'صلاحية الموقع مرفوضة نهائيًا. فعّلها من إعدادات الجهاز.',
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      await customerRepository.updateCustomerLocation(
        customerId: customerId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      emit(
        CustomerLocationSuccess(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      emit(
        CustomerLocationError(
          e.toString(),
        ),
      );
    }
  }
}