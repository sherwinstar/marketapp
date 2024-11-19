// providers/market_provider.dart
import 'package:flutter/material.dart';
import '../model/market_model.dart';

class MarketProvider with ChangeNotifier {
  final List<MarketModel> _allData;
  List<MarketModel> _filteredData = [];
  String _searchQuery = '';
  int _currentTab = 0;
  SortColumn _sortColumn = SortColumn.none;
  SortOrder _sortOrder = SortOrder.default_;
  final TextEditingController searchController = TextEditingController();

  static const List<String> priorityBases = ['BTC', 'ETH', 'WOO'];
  static const List<String> quoteOrder = ['USDT', 'USDC', 'PERP'];

  MarketProvider(this._allData) {
    _applyDefaultSort();
  }

  List<MarketModel> get displayData => _filteredData;
  SortColumn get sortColumn => _sortColumn;
  SortOrder get sortOrder => _sortOrder;

  void _applyDefaultSort() {
    _filteredData = List.from(_allData);
    _filterByTab();
    _applySort();
  }

  void setTab(int index) {
    _currentTab = index;
    searchController.clear();
    _searchQuery = '';
    _sortColumn = SortColumn.none;
    _sortOrder = SortOrder.default_;
    _applyDefaultSort();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _filteredData = _allData.where((item) {
      return item.symbol.toLowerCase().contains(_searchQuery);
    }).toList();
    _filterByTab();
    _applySort();
    notifyListeners();
  }

  void _filterByTab() {
    if (_currentTab == 1) {
      _filteredData = _filteredData.where((item) => item.type == MarketType.SPOT).toList();
    } else if (_currentTab == 2) {
      _filteredData = _filteredData.where((item) => item.type == MarketType.FUTURES).toList();
    }
  }

  void sort(SortColumn column) {
    if (_sortColumn == column) {
      // 切换排序顺序：升序 -> 降序 -> 默认
      switch (_sortOrder) {
        case SortOrder.default_:
          _sortOrder = SortOrder.ascending;
          break;
        case SortOrder.ascending:
          _sortOrder = SortOrder.descending;
          break;
        case SortOrder.descending:
          _sortOrder = SortOrder.default_;
          _sortColumn = SortColumn.none;
          break;
      }
    } else {
      // 新的列：开始升序排序
      _sortColumn = column;
      _sortOrder = SortOrder.ascending;
    }
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    if (_sortOrder == SortOrder.default_ || _sortColumn == SortColumn.none) {
      _applyDefaultSortRule();
      return;
    }

    // 应用用户选择的排序
    switch (_sortColumn) {
      case SortColumn.symbol:
        _sortBySymbol();
        break;
      case SortColumn.lastPrice:
        _sortByLastPrice();
        break;
      case SortColumn.volume:
        _sortByVolume();
        break;
      case SortColumn.none:
        break;
    }
  }

  void _applyDefaultSortRule() {
    // 默认排序规则
    _filteredData.sort((a, b) {
      // 1. 优先级基础货币排序
      int aPriorityIndex = priorityBases.indexOf(a.base);
      int bPriorityIndex = priorityBases.indexOf(b.base);

      if (aPriorityIndex != -1 && bPriorityIndex != -1) {
        if (aPriorityIndex != bPriorityIndex) {
          return aPriorityIndex.compareTo(bPriorityIndex);
        }
      } else if (aPriorityIndex != -1) return -1;
      else if (bPriorityIndex != -1) return 1;

      // 2. 相同基础货币按照报价货币优先级排序
      if (a.base == b.base) {
        int result = _compareByQuote(a.quote, b.quote);
        if (result != 0) return result;
      }

      // 3. 标签页特定的排序规则
      if (_currentTab == 0) {
        // ALL标签：按Symbol字母顺序升序
        return a.symbol.compareTo(b.symbol);
      } else {
        // SPOT和FUTURES标签：按Volume降序
        return b.volume.compareTo(a.volume);
      }
    });
  }

  void _sortBySymbol() {
    _filteredData.sort((a, b) {
      int baseCompare = a.base.compareTo(b.base);
      if (baseCompare != 0) return _sortOrder == SortOrder.ascending ? baseCompare : -baseCompare;

      int quoteCompare = a.quote.compareTo(b.quote);
      if (quoteCompare != 0) return _sortOrder == SortOrder.ascending ? quoteCompare : -quoteCompare;

      return _sortOrder == SortOrder.ascending
          ? a.type.index.compareTo(b.type.index)
          : b.type.index.compareTo(a.type.index);
    });
  }

  void _sortByLastPrice() {
    _filteredData.sort((a, b) => _sortOrder == SortOrder.ascending
        ? a.lastPrice.compareTo(b.lastPrice)
        : b.lastPrice.compareTo(a.lastPrice));
  }

  void _sortByVolume() {
    _filteredData.sort((a, b) => _sortOrder == SortOrder.ascending
        ? a.volume.compareTo(b.volume)
        : b.volume.compareTo(a.volume));
  }

  int _compareByQuote(String quoteA, String quoteB) {
    int aIndex = quoteOrder.indexOf(quoteA);
    int bIndex = quoteOrder.indexOf(quoteB);

    if (aIndex != -1 && bIndex != -1) {
      return aIndex.compareTo(bIndex);
    }
    if (aIndex != -1) return -1;
    if (bIndex != -1) return 1;
    return quoteA.compareTo(quoteB);
  }
}