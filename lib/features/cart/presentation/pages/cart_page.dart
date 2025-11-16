import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cert_classroom_mobile/core/theme/app_theme.dart';
import 'package:cert_classroom_mobile/core/utils/custom_snackbar.dart';
import 'package:cert_classroom_mobile/core/utils/formatters.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/cart_snapshot.dart';
import 'package:cert_classroom_mobile/features/cart/data/models/checkout.dart';
import 'package:cert_classroom_mobile/features/cart/presentation/controllers/cart_controller.dart';
import 'package:cert_classroom_mobile/shared/controllers/student_session_controller.dart';
import 'package:cert_classroom_mobile/shared/widgets/loading_indicator.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartController>(
      create:
          (_) =>
              CartController(session: context.read<StudentSessionController>()),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, controller, _) {
        final snapshot = controller.snapshot;
        if (controller.isMutating && snapshot.isEmpty) {
          return const LoadingIndicator(message: 'Đang đồng bộ giỏ hàng...');
        }
        if (snapshot.isEmpty) {
          return const _CartEmptyState();
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _CartHeader(snapshot: snapshot),
                _SelectionBar(controller: controller, snapshot: snapshot),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh:
                        () => context
                            .read<StudentSessionController>()
                            .refreshCart(force: true),
                    child: ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      children: [
                        ...snapshot.courses.map(
                          (course) =>
                              _CourseTile(item: course, controller: controller),
                        ),
                        ...snapshot.combos.map(
                          (combo) =>
                              _ComboTile(item: combo, controller: controller),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _CheckoutBar(controller: controller),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.snapshot});

  final CartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giỏ hàng của bạn',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${snapshot.counts.total} sản phẩm • ${formatCurrency(snapshot.totals.grand)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.controller, required this.snapshot});

  final CartController controller;
  final CartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        controller.selectedCourseIds.length +
        controller.selectedComboIds.length;
    final allSelected =
        selectedCount == snapshot.counts.total && snapshot.counts.total != 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: (value) => controller.toggleAll(value ?? false),
          ),
          const SizedBox(width: 4),
          Text(
            allSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed:
                controller.hasSelection
                    ? () => _handleRemoveSelected(context, selectedCount)
                    : null,
            icon: const Icon(Icons.delete_outline),
            label: Text(
              'Xóa ($selectedCount)',
              style: TextStyle(
                color:
                    controller.hasSelection
                        ? AppColors.danger
                        : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemoveSelected(
    BuildContext context,
    int selectedCount,
  ) async {
    try {
      await controller.removeSelected();
      if (!context.mounted) return;
      final message =
          selectedCount > 1
              ? 'Đã xóa $selectedCount sản phẩm khỏi giỏ hàng'
              : 'Đã xóa sản phẩm khỏi giỏ hàng';
      showCustomSnackbar(
        context: context,
        message: message,
        lottiePath: 'assets/lottie/success.json',
        backgroundColor: Colors.green.shade50,
        textColor: Colors.green.shade900,
      );
    } catch (error) {
      if (!context.mounted) return;
      showCustomSnackbar(
        context: context,
        message: error.toString(),
        lottiePath: 'assets/lottie/error.json',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
    }
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.item, required this.controller});

  final CartCourseItem item;
  final CartController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedCourseIds.contains(item.id);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => controller.toggleCourse(item.id),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.coverImage ??
                    'https://images.unsplash.com/photo-1551434678-e076c223a692?w=200',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.teacher ?? 'Mentor OCC',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(item.price),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeCourse(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeCourse(BuildContext context) async {
    try {
      await controller.removeCourse(item.id);
      if (!context.mounted) return;
      showCustomSnackbar(
        context: context,
        message: 'Đã xóa "${item.title}" khỏi giỏ hàng',
        lottiePath: 'assets/lottie/success.json',
        backgroundColor: Colors.green.shade50,
        textColor: Colors.green.shade900,
      );
    } catch (error) {
      if (!context.mounted) return;
      showCustomSnackbar(
        context: context,
        message: error.toString(),
        lottiePath: 'assets/lottie/error.json',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
    }
  }
}

class _ComboTile extends StatelessWidget {
  const _ComboTile({required this.item, required this.controller});

  final CartComboItem item;
  final CartController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedComboIds.contains(item.id);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => controller.toggleCombo(item.id),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.coverImage ??
                    'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=200',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.courseCount ?? 0} khóa học',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(item.price),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeCombo(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeCombo(BuildContext context) async {
    try {
      await controller.removeCombo(item.id);
      if (!context.mounted) return;
      showCustomSnackbar(
        context: context,
        message: 'Đã xóa combo "${item.title}" khỏi giỏ hàng',
        lottiePath: 'assets/lottie/success.json',
        backgroundColor: Colors.green.shade50,
        textColor: Colors.green.shade900,
      );
    } catch (error) {
      if (!context.mounted) return;
      showCustomSnackbar(
        context: context,
        message: error.toString(),
        lottiePath: 'assets/lottie/error.json',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
    }
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              Text(
                formatCurrency(snapshot.totals.grand),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  snapshot.isEmpty
                      ? null
                      : () => _showCheckoutSheet(context, controller),
              child: const Text('Tiến hành thanh toán'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showCheckoutSheet(
  BuildContext context,
  CartController controller,
) async {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _CheckoutSheet(controller: controller),
  );
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.controller});

  final CartController controller;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  CheckoutPreview? _preview;
  String _method = 'qr';
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreview());
  }

  Future<void> _loadPreview() async {
    try {
      final preview = await widget.controller.previewCheckout();
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      showCustomSnackbar(
        context: context,
        message: error.toString(),
        lottiePath: 'assets/lottie/error.json',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _complete() async {
    setState(() => _submitting = true);
    try {
      final result = await widget.controller.completeCheckout(_method);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (result != null) {
        _showCheckoutSuccess(context, result);
      }
    } catch (error) {
      if (!mounted) return;
      showCustomSnackbar(
        context: context,
        message: error.toString(),
        lottiePath: 'assets/lottie/error.json',
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade900,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child:
          _loading
              ? const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingIndicator(message: 'Đang chuẩn bị thanh toán...'),
              )
              : _CheckoutContent(
                preview: _preview!,
                method: _method,
                onMethodChanged: (value) => setState(() => _method = value),
                onSubmit: _submitting ? null : _complete,
                submitting: _submitting,
              ),
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.preview,
    required this.method,
    required this.onMethodChanged,
    required this.onSubmit,
    required this.submitting,
  });

  final CheckoutPreview preview;
  final String method;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback? onSubmit;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Xác nhận thanh toán',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Phương thức chấp nhận: QR Pay, Chuyển khoản ngân hàng, Thẻ Visa/Master. VNPay tạm thời không hỗ trợ.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            ...preview.courses.map(
              (course) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(course.title),
                subtitle: const Text('Khóa học'),
                trailing: Text(formatCurrency(course.price)),
              ),
            ),
            ...preview.combos.map(
              (combo) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(combo.title),
                subtitle: const Text('Combo'),
                trailing: Text(formatCurrency(combo.price)),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng thanh toán'),
                Text(
                  formatCurrency(preview.total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PaymentRadio(
              label: 'QR Pay OCC',
              value: 'qr',
              groupValue: method,
              onChanged: onMethodChanged,
              icon: Icons.qr_code,
            ),
            _PaymentRadio(
              label: 'Chuyển khoản ngân hàng',
              value: 'bank',
              groupValue: method,
              onChanged: onMethodChanged,
              icon: Icons.account_balance,
            ),
            _PaymentRadio(
              label: 'Thẻ Visa/Master',
              value: 'visa',
              groupValue: method,
              onChanged: onMethodChanged,
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSubmit,
                child:
                    submitting
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Xác nhận thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRadio extends StatelessWidget {
  const _PaymentRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.muted,
      ),
      title: Text(label),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
      onTap: () => onChanged(value),
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh:
            () => context.read<StudentSessionController>().refreshCart(
              force: true,
            ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Giỏ hàng đang trống',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hãy khám phá các khóa học và combo để bắt đầu hành trình học tập.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showCheckoutSuccess(BuildContext context, CheckoutResult result) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Thanh toán thành công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phương thức: ${result.paymentMethod.toUpperCase()}'),
            if (result.invoiceId != null) ...[
              const SizedBox(height: 4),
              Text('Mã hóa đơn: ${result.invoiceId}'),
            ],
            const SizedBox(height: 8),
            Text('Tổng tiền: ${formatCurrency(result.total)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hoàn tất'),
          ),
        ],
      );
    },
  );
}
