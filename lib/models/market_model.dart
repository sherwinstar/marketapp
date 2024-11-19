// models/market_model.dart
enum MarketType { SPOT, FUTURES }
enum SortDirection { none, asc, desc }
enum SortColumn { symbol, lastPrice, volume, none }
enum SortOrder { ascending, descending, default_ }

class MarketModel {
  final String base;
  final String quote;
  final MarketType type;
  final double lastPrice;
  final double volume;

  MarketModel({
    required this.base,
    required this.quote,
    required this.type,
    required this.lastPrice,
    required this.volume,
  });

  String get symbol => type == MarketType.SPOT
      ? '$base/$quote'
      : '$base-PERP';
}