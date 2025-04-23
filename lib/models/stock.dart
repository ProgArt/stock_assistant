class Stock {
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

  Stock({
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

  factory Stock.fromJson(Map<String, dynamic> json) {
    double currPrice = double.tryParse(json['trade']?.toString() ?? '0') ?? 0;
    double priceChange = double.tryParse(json['pricechange']?.toString() ?? '0') ?? 0;
    double changePercent = double.tryParse(json['changepercent']?.toString() ?? '0') ?? 0;
    double leftPrice = double.tryParse(json['settlement']?.toString() ?? '0') ?? 0;

    if (currPrice == 0) {
      currPrice = double.tryParse(json['buy']?.toString() ?? '0') ?? 0;
    }
    if (currPrice == 0) {
      currPrice = double.tryParse(json['sell']?.toString() ?? '0') ?? 0;
    }
    if (priceChange == 0 && currPrice !=0) {
      priceChange = currPrice - leftPrice;
    }
    if (changePercent == 0 && leftPrice !=0) {
      changePercent = priceChange / leftPrice * 100;
    }

    return Stock(
      symbol: json['symbol'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      trade: currPrice,
      priceChange: priceChange,
      changePercent: changePercent,
      volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      turnoverRatio: double.tryParse(json['turnoverratio']?.toString() ?? '0') ?? 0,
      mktcap: double.tryParse(json['mktcap']?.toString() ?? '0') ?? 0,
    );
  }
} 