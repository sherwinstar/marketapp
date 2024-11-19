// screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/market_model.dart';
import '../providers/market_provider.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: DefaultTabController.of(context),
          tabs: const [
            Tab(text: 'ALL'),
            Tab(text: 'SPOT'),
            Tab(text: 'FUTURES'),
          ],
          onTap: (index) {
            Provider.of<MarketProvider>(context, listen: false).setTab(index);
          },
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<MarketProvider>(
        builder: (context, provider, _) {
          return TextField(
            controller: provider.searchController, // 使用 provider 中的 controller
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: provider.search,
          );
        },
      ),
    );
  }

  Widget _buildTable() {
    return Consumer<MarketProvider>(
      builder: (context, provider, _) {
        final data = provider.displayData;

        if (data.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal, // 添加横向滚动支持
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 20,
              columns: [
                _buildColumn('Symbol', SortColumn.symbol, provider, false),
                _buildColumn('Last Price', SortColumn.lastPrice, provider, true),
                _buildColumn('Volume', SortColumn.volume, provider, true),
              ],
              rows: data.map((item) => DataRow(
                cells: [
                  DataCell(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(item.symbol),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('\$${_formatPrice(item.lastPrice)}'),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(_formatVolume(item.volume)),
                    ),
                  ),
                ],
              )).toList(),
            ),
          ),
        );
      },
    );
  }

// screens/market_screen.dart
  DataColumn _buildColumn(
      String label,
      SortColumn column,
      MarketProvider provider,
      bool numeric) {
    return DataColumn(
      label: Container(
        alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: provider.sortColumn == column
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (provider.sortColumn == column) ...[
              SizedBox(width: 4),
              Icon(
                provider.sortOrder == SortOrder.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
              ),
            ],
          ],
        ),
      ),
      numeric: numeric,
      onSort: (_, __) => provider.sort(column),
    );
  }

  String _formatPrice(double price) {
    return NumberFormat('#,##0.00').format(price);
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) {
      return '\$${(volume / 1e9).toStringAsFixed(1)}B';
    } else if (volume >= 1e6) {
      return '\$${(volume / 1e6).toStringAsFixed(2)}M';
    } else if (volume >= 1e3) {
      return '\$${(volume / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${volume.toStringAsFixed(2)}';
  }
}