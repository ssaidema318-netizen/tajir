import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_cubit.dart';
import 'package:tajir/features/sales/presentation/cubit/create_sale_state.dart';

import '../../../../core/theme/app_spacing.dart';


class SaleCustomerSection extends StatefulWidget {
  final CreateSaleLoaded state;
  final CreateSaleCubit cubit;

  const SaleCustomerSection({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  State<SaleCustomerSection> createState() =>
      _SaleCustomerSectionState();
}

class _SaleCustomerSectionState
    extends State<SaleCustomerSection> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController idNumberController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final draft = widget.state.customerDraft;

    nameController = TextEditingController(
      text: draft.name,
    );

    phoneController = TextEditingController(
      text: draft.phone,
    );

    addressController = TextEditingController(
      text: draft.address ?? '',
    );

    idNumberController = TextEditingController(
      text: draft.idNumber ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    idNumberController.dispose();

    super.dispose();
  }

  Future<void> _pickCustomerImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    widget.cubit.updateCustomerDraft(
      customerImagePath: image.path,
    );
  }

  Future<void> _pickIdImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    widget.cubit.updateCustomerDraft(
      idImagePath: image.path,
    );
  }

  Future<void> _showCustomerPicker() async {
    final customer = await showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _CustomerPicker(
          customers: widget.state.customers,
        );
      },
    );

    if (customer == null) return;

    widget.cubit.selectCustomer(customer);

    nameController.text = customer.name;
    phoneController.text = customer.phone;
    addressController.text = customer.address ?? '';
    idNumberController.text = customer.idNumber ?? '';

    widget.cubit.updateCustomerDraft(
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      idNumber: customer.idNumber,
      idImagePath: customer.idImagePath,
      customerImagePath: customer.customerImagePath,
      latitude: customer.latitude,
      longitude: customer.longitude,
    );
  }

  void _startNewCustomer() {
    widget.cubit.clearCustomer();

    nameController.clear();
    phoneController.clear();
    addressController.clear();
    idNumberController.clear();

    widget.cubit.updateCustomerDraft(
      name: '',
      phone: '',
      address: '',
      idNumber: '',
      idImagePath: '',
      customerImagePath: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.state.customerDraft;
    final selectedCustomer =
        widget.state.selectedCustomer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات العميل',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            // اختيار عميل موجود
            OutlinedButton.icon(
              onPressed: _showCustomerPicker,
              icon: const Icon(
                Icons.person_search_outlined,
              ),
              label: Text(
                selectedCustomer == null
                    ? 'اختيار عميل موجود'
                    : 'تغيير العميل',
              ),
            ),

            if (selectedCustomer != null) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: Text(
                        'العميل المختار: ${selectedCustomer.name}',
                      ),
                    ),
                    IconButton(
                      onPressed: _startNewCustomer,
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(
              height: AppSpacing.lg,
            ),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العميل',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              onChanged: (value) {
                widget.cubit.updateCustomerDraft(
                  name: value,
                );
              },
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
              ),
              onChanged: (value) {
                widget.cubit.updateCustomerDraft(
                  phone: value,
                );
              },
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
              ),
              onChanged: (value) {
                widget.cubit.updateCustomerDraft(
                  address: value,
                );
              },
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: idNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم الهوية',
                prefixIcon: Icon(
                  Icons.badge_outlined,
                ),
              ),
              onChanged: (value) {
                widget.cubit.updateCustomerDraft(
                  idNumber: value,
                );
              },
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Row(
              children: [
                Expanded(
                  child: _ImageButton(
                    title: 'صورة العميل',
                    icon: Icons.person,
                    imagePath:
                        draft.customerImagePath,
                    onPressed:
                        _pickCustomerImage,
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.md,
                ),

                Expanded(
                  child: _ImageButton(
                    title: 'صورة الهوية',
                    icon: Icons.badge,
                    imagePath:
                        draft.idImagePath,
                    onPressed: _pickIdImage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerPicker extends StatefulWidget {
  final List<CustomerModel> customers;

  const _CustomerPicker({
    required this.customers,
  });

  @override
  State<_CustomerPicker> createState() =>
      _CustomerPickerState();
}

class _CustomerPickerState
    extends State<_CustomerPicker> {
  String search = '';

  List<CustomerModel> get filteredCustomers {
    final query = search.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.customers;
    }

    return widget.customers.where((customer) {
      return customer.name
              .toLowerCase()
              .contains(query) ||
          customer.phone
              .toLowerCase()
              .contains(query) ||
          (customer.idNumber ?? '')
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Text(
                'اختيار العميل',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              TextField(
                autofocus: true,
                decoration:
                    const InputDecoration(
                  hintText:
                      'ابحث بالاسم أو الهاتف أو الهوية',
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Expanded(
                child: filteredCustomers.isEmpty
                    ? const Center(
                        child: Text(
                          'لا يوجد عملاء مطابقون',
                        ),
                      )
                    : ListView.separated(
                        itemCount:
                            filteredCustomers.length,
                        separatorBuilder:
                            (_, _) {
                          return const Divider();
                        },
                        itemBuilder:
                            (context, index) {
                          final customer =
                              filteredCustomers[
                                  index];

                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.person,
                              ),
                            ),
                            title: Text(
                              customer.name,
                            ),
                            subtitle: Text(
                              customer.phone,
                            ),
                            onTap: () {
                              Navigator.pop(
                                context,
                                customer,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? imagePath;
  final VoidCallback onPressed;

  const _ImageButton({
    required this.title,
    required this.icon,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  Text(title),
                ],
              ),
      ),
    );
  }
}