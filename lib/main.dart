import 'package:flutter/material.dart';
import 'package:marketapp/screens/market_screen.dart';
import 'package:provider/provider.dart';

import 'data/market_data.dart';
import 'model/market_model.dart';
import 'providers/market_provider.dart';

void main() {
  final List<MarketModel> initialData = marketRawData.map((item) => MarketModel(
    base: item['base'],
    quote: item['quote'],
    type: item['type'] == 'SPOT' ? MarketType.SPOT : MarketType.FUTURES,
    lastPrice: item['lastPrice'],
    volume: item['volume'],
  )).toList();

  runApp(
    ChangeNotifierProvider(
      create: (_) => MarketProvider(initialData),
      child: MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: MarketScreen(),
        ),
      ),
    ),
  );

  // runApp(
  //   ChangeNotifierProvider(
  //     create: (_) => MarketProvider(initialData),
  //     child: MaterialApp(
  //       home: MarketScreen(),
  //     ),
  //   ),
  // );
}