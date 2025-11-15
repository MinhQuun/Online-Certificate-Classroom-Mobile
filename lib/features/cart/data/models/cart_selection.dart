class CartSelection {
  const CartSelection({this.courseIds = const [], this.comboIds = const []});

  final List<int> courseIds;
  final List<int> comboIds;

  bool get isEmpty => courseIds.isEmpty && comboIds.isEmpty;

  CartSelection copyWith({List<int>? courseIds, List<int>? comboIds}) {
    return CartSelection(
      courseIds: courseIds ?? this.courseIds,
      comboIds: comboIds ?? this.comboIds,
    );
  }

  Map<String, dynamic> toPayload() {
    return {'courses': courseIds, 'combos': comboIds};
  }
}
