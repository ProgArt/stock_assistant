class StockIndex {
  final String symbol;
  final String code;
  final String name;
  final double trade;
  final double priceChange;
  final double changePercent;
  final double volume;
  final double amount;
  final double turnoverRatio;
  final double mktcap;

  StockIndex({
    required this.symbol,
    required this.code,
    required this.name,
    required this.trade,
    required this.priceChange,
    required this.changePercent,
    required this.volume,
    required this.amount,
    required this.turnoverRatio,
    required this.mktcap,
  });

  factory StockIndex.fromJson(Map<String, dynamic> json) {
    return StockIndex(
      symbol: json['symbol'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      trade: double.tryParse(json['trade']?.toString() ?? '0') ?? 0,
      priceChange: double.tryParse(json['pricechange']?.toString() ?? '0') ?? 0,
      changePercent: double.tryParse(json['changepercent']?.toString() ?? '0') ?? 0,
      volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      turnoverRatio: double.tryParse(json['turnoverratio']?.toString() ?? '0') ?? 0,
      mktcap: double.tryParse(json['mktcap']?.toString() ?? '0') ?? 0,
    );
  }
} 