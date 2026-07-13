import 'dart:io';

import 'mt4_parser.dart';
import 'ctrader_parser.dart';
import 'tradingview_parser.dart';
import 'crypto_exchange_parser.dart';

/// Auto-detects broker/platform format and parses CSV accordingly.
enum BrokerFormat { mt4, mt5, ctrader, tradingview, binance, bybit, unknown }

class BrokerDetector {
  BrokerDetector._();

  /// Detect the format from CSV content.
  static BrokerFormat detect(String csv) {
    if (MT4Parser.looksLikeMT4(csv)) return BrokerFormat.mt4;
    if (CTraderParser.looksLikeCTrader(csv)) return BrokerFormat.ctrader;
    if (TradingViewParser.looksLikeTradingView(csv))
      return BrokerFormat.tradingview;
    if (CryptoExchangeParser.looksLikeBybit(csv)) return BrokerFormat.bybit;
    if (CryptoExchangeParser.looksLikeBinance(csv)) return BrokerFormat.binance;
    // MT5 detection handled by existing parser
    return BrokerFormat.unknown;
  }

  /// Parse a CSV file, auto-detecting format.
  /// Returns (format, trades) tuple.
  /// [symbol] is used for TradingView which doesn't include symbol per-row.
  static Future<(BrokerFormat, List<Map<String, dynamic>>)> parseFile(
    File file, {
    String? symbol,
  }) async {
    final content = await file.readAsString();
    final format = detect(content);

    switch (format) {
      case BrokerFormat.mt4:
        return (format, MT4Parser.parseString(content));
      case BrokerFormat.ctrader:
        return (format, CTraderParser.parseString(content));
      case BrokerFormat.tradingview:
        return (format, TradingViewParser.parseString(content, symbol: symbol));
      case BrokerFormat.binance:
      case BrokerFormat.bybit:
        return (format, CryptoExchangeParser.parseString(content));
      default:
        return (BrokerFormat.unknown, <Map<String, dynamic>>[]);
    }
  }

  /// Human-readable label for each format.
  static String label(BrokerFormat f) {
    switch (f) {
      case BrokerFormat.mt4:
        return 'MetaTrader 4';
      case BrokerFormat.mt5:
        return 'MetaTrader 5';
      case BrokerFormat.ctrader:
        return 'cTrader';
      case BrokerFormat.tradingview:
        return 'TradingView';
      case BrokerFormat.binance:
        return 'Binance';
      case BrokerFormat.bybit:
        return 'Bybit';
      case BrokerFormat.unknown:
        return 'Unknown';
    }
  }
}
