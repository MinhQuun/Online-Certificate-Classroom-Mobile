import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/formatters.dart';
import 'package:cert_classroom_mobile/features/orders/data/models/order.dart';
import 'package:cert_classroom_mobile/features/orders/presentation/controllers/orders_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/error_view.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersController()..loadOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.orders.isEmpty) {
          return const LoadingIndicator(
            message: 'Đang tải lịch sử đơn hàng...',
          );
        }

        if (controller.errorMessage != null && controller.orders.isEmpty) {
          return ErrorView(
            title: 'Không thể tải đơn hàng',
            message: controller.errorMessage,
            onRetry: () => controller.loadOrders(refresh: true),
          );
        }

        if (controller.orders.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.loadOrders(refresh: true),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: const [
                    SliverToBoxAdapter(child: _OrdersHeader()),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Chưa có đơn hàng nào. Hãy đặt khóa học để xem lại lịch sử tại đây.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final paidTotal = controller.orders
            .where(
              (order) => _statusMeta(order.status).tone == _OrderTone.success,
            )
            .fold<int>(0, (sum, order) => sum + order.total);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => controller.loadOrders(refresh: true),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: _OrdersHeader()),
                  SliverToBoxAdapter(
                    child: _OrdersHero(
                      totalOrders: controller.orders.length,
                      paidTotal: paidTotal,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _StatusFilters(
                      active: controller.activeFilter,
                      onChanged:
                          (filter) => controller.loadOrders(
                            status: filter,
                            refresh: true,
                          ),
                    ),
                  ),
                  if (controller.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) {
                        final order = controller.orders[index];
                        return _OrderCard(
                          order: order,
                          onTap: () => _showOrderDetail(context, order),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemCount: controller.orders.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOrderDetail(BuildContext context, OrderSummary order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final meta = _statusMeta(order.status);
        final paymentLabel = _friendlyPayment(order.paymentMethod);
        final invoiceLabel = order.invoiceId ?? order.code;
        final dateLabel =
            formatDateLabel(order.createdAt?.toIso8601String()) ?? '--';
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.muted.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatusChip(meta: meta),
                      const Spacer(),
                      Text(
                        order.code,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tổng thanh toán',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(order.total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MetaRow(
                    label: 'Thanh toán',
                    value: paymentLabel,
                    icon: Icons.payments_outlined,
                  ),
                  _MetaRow(
                    label: 'Ngày đặt',
                    value: dateLabel,
                    icon: Icons.event,
                  ),
                  _MetaRow(
                    label: 'Mã hóa đơn',
                    value: invoiceLabel,
                    icon: Icons.receipt_long_outlined,
                  ),
                  if (order.note != null && order.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Ghi chú',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.note!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Sản phẩm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.items.isEmpty)
                    Text(
                      'Chưa có sản phẩm trong đơn này.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    )
                  else
                    ...order.items.map((item) => _OrderItemTile(item: item)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 4),
          Text(
            'Lịch sử đơn hàng',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _OrdersHero extends StatelessWidget {
  const _OrdersHero({required this.totalOrders, required this.paidTotal});

  final int totalOrders;
  final int paidTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lịch sử đơn hàng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Theo dõi các đơn đã mua, tải mã hóa đơn và kiểm tra trạng thái thanh toán.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeroStat(
                  label: 'Tổng đơn',
                  value: '$totalOrders',
                  icon: Icons.list_alt_outlined,
                ),
                const SizedBox(width: 12),
                _HeroStat(
                  label: 'Đã thanh toán',
                  value: formatCurrency(paidTotal, compact: true),
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'Tất cả'),
      ('paid', 'Đã thanh toán'),
      ('pending', 'Chờ xử lý'),
      ('failed', 'Thất bại'),
      ('cancelled', 'Đã hủy'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children:
            filters
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter.$2),
                      selected: active == filter.$1,
                      onSelected: (_) => onChanged(filter.$1),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(order.status);
    final dateLabel =
        formatDateLabel(order.createdAt?.toIso8601String()) ?? 'Không rõ ngày';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(meta: meta),
                const Spacer(),
                Text(
                  order.code,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  order.items
                      .take(3)
                      .map((item) => _ItemPill(item: item))
                      .toList(),
            ),
            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+${order.items.length - 3} sản phẩm khác',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(order.total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Xem chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPill extends StatelessWidget {
  const _ItemPill({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.type.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image:
                  item.coverImage == null
                      ? null
                      : DecorationImage(
                        image: NetworkImage(item.coverImage!),
                        fit: BoxFit.cover,
                      ),
            ),
            child:
                item.coverImage == null
                    ? const Icon(Icons.menu_book_outlined, size: 18)
                    : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$typeLabel · ${formatCurrency(item.price)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            item.coverImage == null
                ? Container(
                  width: 48,
                  height: 48,
                  color: AppColors.primarySoft.withValues(alpha: 0.18),
                  child: const Icon(Icons.menu_book_outlined),
                )
                : Image.network(
                  item.coverImage!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
      ),
      title: Text(item.title),
      subtitle: Text(
        '${item.type.toUpperCase()} · x${item.quantity}',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
      ),
      trailing: Text(formatCurrency(item.price)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.meta});

  final _StatusMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: meta.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 16, color: meta.color),
          const SizedBox(width: 6),
          Text(
            meta.label,
            style: TextStyle(color: meta.color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _OrderTone { success, warning, danger, info }

class _StatusMeta {
  const _StatusMeta({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.tone,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final _OrderTone tone;
}

String _friendlyPayment(String? raw) {
  if (raw == null || raw.isEmpty) return 'Chưa rõ';
  final value = raw.toLowerCase();
  if (value.contains('qr')) return 'QR Pay';
  if (value.contains('visa') || value.contains('master'))
    return 'Thẻ VISA/Master';
  if (value.contains('bank')) return 'Chuyển khoản ngân hàng';
  if (value.contains('vnpay')) return 'VNPay';
  return raw.toUpperCase();
}

_StatusMeta _statusMeta(String status) {
  final normalized = status.toUpperCase();
  switch (normalized) {
    case 'PAID':
    case 'COMPLETED':
    case 'SUCCESS':
      return const _StatusMeta(
        label: 'Đã thanh toán',
        color: AppColors.success,
        background: AppColors.successTint,
        icon: Icons.check_circle,
        tone: _OrderTone.success,
      );
    case 'PENDING':
    case 'PROCESSING':
      return const _StatusMeta(
        label: 'Đang xử lý',
        color: AppColors.warning,
        background: AppColors.warningTint,
        icon: Icons.hourglass_bottom,
        tone: _OrderTone.warning,
      );
    case 'CANCELLED':
    case 'REFUNDED':
      return const _StatusMeta(
        label: 'Đã hủy/Hoàn tiền',
        color: AppColors.info,
        background: AppColors.infoTint,
        icon: Icons.replay_outlined,
        tone: _OrderTone.info,
      );
    case 'FAILED':
    case 'DECLINED':
      return const _StatusMeta(
        label: 'Thanh toán thất bại',
        color: AppColors.danger,
        background: AppColors.dangerTint,
        icon: Icons.error_outline,
        tone: _OrderTone.danger,
      );
    default:
      return const _StatusMeta(
        label: 'Không xác định',
        color: AppColors.muted,
        background: Color(0xFFE2E8F0),
        icon: Icons.help_outline,
        tone: _OrderTone.info,
      );
  }
}
