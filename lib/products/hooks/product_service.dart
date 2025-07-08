import '../models/product_model.dart';

enum FilterType {
  all,
  newest,
  popular,
  man,
  woman,
  unisex,
}

class ProductFilterService {
  static final ProductFilterService _instance =
      ProductFilterService._internal();
  factory ProductFilterService() => _instance;
  ProductFilterService._internal();

  // Filter products based on filter type
  List<ProductModel> filterProducts(
      List<ProductModel> products, FilterType filterType) {
    switch (filterType) {
      case FilterType.all:
        return _filterAll(products);
      case FilterType.newest:
        return _filterNewest(products);
      case FilterType.popular:
        return _filterPopular(products);
      case FilterType.man:
        return _filterMen(products);
      case FilterType.woman:
        return _filterWomen(products);
      case FilterType.unisex:
        return _filterUnisex(products);
    }
  }

  // Filter products by index (for backward compatibility)
  List<ProductModel> filterProductsByIndex(
      List<ProductModel> products, int index) {
    final filterType = _getFilterTypeFromIndex(index);
    return filterProducts(products, filterType);
  }

  // Convert index to FilterType
  FilterType _getFilterTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return FilterType.all;
      case 1:
        return FilterType.newest;
      case 2:
        return FilterType.popular;
      case 3:
        return FilterType.man;
      case 4:
        return FilterType.woman;
        case 5:
        return FilterType.unisex;
      default:
        return FilterType.all;
    }
  }

  // Filter implementations
  List<ProductModel> _filterAll(List<ProductModel> products) {
    return List.from(products);
  }

  List<ProductModel> _filterNewest(List<ProductModel> products) {
    final filteredProducts = products.where((product) {
      return product.createdDate != null;
    }).toList();

    // sort by newest first (latest date first)
    filteredProducts.sort((a, b) => b.createdDate.compareTo(a.createdDate));

    return filteredProducts;
  }

  List<ProductModel> _filterPopular(List<ProductModel> products) {
    final filteredProducts = products.where((product) {
      // Filter by rating (popular products have rating >= 4.0)
      return product.rating >= 4.0;
    }).toList();

    // Sort by rating (highest first)
    filteredProducts.sort((a, b) {
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    });

    return filteredProducts;
  }

  List<ProductModel> _filterMen(List<ProductModel> products) {
    return products.where((product) {
      return product.productType.toLowerCase() == 'man' ||
          product.productType.toLowerCase() == 'men';
    }).toList();
  }

  List<ProductModel> _filterWomen(List<ProductModel> products) {
    return products.where((product) {
      return product.productType.toLowerCase() == 'woman' ||
          product.productType.toLowerCase() == 'women';
    }).toList();
  }

  List<ProductModel> _filterUnisex(List<ProductModel> products) {
    return products.where((product) {
      return product.productType.toLowerCase() == 'unisex';
      //  || product.productType?.toLowerCase() == 'women';
    }).toList();
  }

  // Get filter description
  String getFilterDescription(int index) {
    switch (index) {
      case 0:
        return 'Showing all products';
      case 1:
        return 'Showing newest products';
      case 2:
        return 'Showing popular products';
      case 3:
        return 'Showing products for men';
      case 4:
        return 'Showing products for women';
      case 5:
        return 'Showing products for unisex';
      default:
        return 'Showing all products';
    }
  }

  // Get filter name
  String getFilterName(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'Newest';
      case 2:
        return 'Popular';
      case 3:
        return 'Man';
      case 4:
        return 'Woman';
      case 5:
        return 'Unisex';
      default:
        return 'All';
    }
  }
}
