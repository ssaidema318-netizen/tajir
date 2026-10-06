
import 'package:flutter/material.dart';
import 'package:tajir/core/theme/app_colors.dart';
import 'package:tajir/core/theme/app_spacing.dart';
import 'package:tajir/features/customers/data/models/customer_model.dart';

class CustomerHeader extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onCall;
  final VoidCallback? onLocation;

  const CustomerHeader({
    super.key,
    required this.customer,
    this.onCall,
    this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = customer.customerImagePath != null &&
        customer.customerImagePath!.isNotEmpty;

    final hasLocation =
        customer.latitude != null && customer.longitude != null;

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(hasImage),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            customer.phone,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (customer.address != null &&
                        customer.address!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customer.address!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_outlined,
                  label: 'اتصال',
                  onTap: onCall,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: _ActionButton(
                  icon: Icons.directions_outlined,
                  label: hasLocation ? 'الموقع' : 'لا يوجد موقع',
                  onTap: hasLocation ? onLocation : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool hasImage) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 2,
        ),
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
    return const Icon(
      Icons.person_outline,
      color: Colors.white,
      size: 34,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.white.withValues(
        alpha: enabled ? 0.14 : 0.07,
      ),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? Colors.white : Colors.white38,
                size: 19,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color:
                      enabled ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

