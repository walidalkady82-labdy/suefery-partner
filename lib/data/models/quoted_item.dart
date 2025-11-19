import 'package:equatable/equatable.dart';

import 'order_model.dart';

class QuotedItem extends Equatable {
  final OrderItemModel item;
  final double quotedPrice;

  const QuotedItem({required this.item, required this.quotedPrice});

  QuotedItem copyWith({
    OrderItemModel? item,
    double? quotedPrice,
  }) {
    return QuotedItem(
      item: item ?? this.item,
      quotedPrice: quotedPrice ?? this.quotedPrice,
    );
  }

  @override
  List<Object> get props => [item, quotedPrice];
}