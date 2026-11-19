import 'package:get/get.dart';
import '../models/order_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/views/cart_screen.dart';
import '../service/order_service.dart';

class OrderController extends GetxController {
  final reorderingIds = <int>{}.obs;

  Future<void> buyAgain(int orderId) async {
    if (reorderingIds.contains(orderId)) return;
    reorderingIds.add(orderId);
    try {
      final result = await OrderService.buyAgain(orderId);
      if (result == null) {
        Get.snackbar('Could not reorder', 'Please try again.');
        return;
      }
      final added = (result['added'] as List).length;
      final skipped = (result['skipped'] as List).length;
      if (added > 0) {
        if (Get.isRegistered<CartController>()) {
          await Get.find<CartController>().fetchCartItems();
        }
        Get.to(() => const CartScreen());
      }
      Get.snackbar(added > 0 ? 'Added to cart' : 'No items added',
          '$added item(s) added, $skipped unavailable or short of stock. Review current prices before checkout.');
    } catch (_) {
      Get.snackbar('Could not reorder', 'Check your cart before trying again.');
    } finally {
      reorderingIds.remove(orderId);
    }
  }

  // Observable lists for different order statuses
  var pendingOrders = <OrderModel>[].obs;
  var deliveredOrders = <OrderModel>[].obs;
  var cancelledOrders = <OrderModel>[].obs;

  // Loading states
  var isPendingLoading = false.obs;
  var isDeliveredLoading = false.obs;
  var isCancelledLoading = false.obs;

  // Error messages
  var pendingError = ''.obs;
  var deliveredError = ''.obs;
  var cancelledError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load all orders when controller initializes
    loadAllOrders();
  }

  final Map<String, Future<void>> _requests = {};

  Future<void> loadAllOrders() async {
    await Future.wait([
      loadOrdersByStatus('Pending'),
      loadOrdersByStatus('Delivered'),
      loadOrdersByStatus('Cancelled'),
    ]);
  }

  String _bucket(String status) => status == 'Shipped' ? 'Pending' : status;

  Future<void> loadOrdersByStatus(String status) {
    final bucket = _bucket(status);
    return _requests[bucket] ??= _loadBucket(bucket).whenComplete(() {
      _requests.remove(bucket);
    });
  }

  Future<void> _loadBucket(String status) async {
    _setLoading(status, true);
    _setError(status, '');
    try {
      final orders = await OrderService.getOrdersByStatus(status);
      if (isClosed) return;
      if (orders == null) {
        _setError(status, 'Could not load your orders. Please try again.');
      } else {
        final unique = <int, OrderModel>{};
        for (final order in orders) {
          if (order.id != null &&
              _bucket(order.deliveryStatus ?? '') == status) {
            unique[order.id!] = order;
          }
        }
        _list(status).assignAll(_sorted(unique.values));
      }
    } catch (_) {
      if (!isClosed)
        _setError(status, 'Could not load your orders. Please try again.');
    } finally {
      if (!isClosed) _setLoading(status, false);
    }
  }

  List<OrderModel> _sorted(Iterable<OrderModel> orders) => orders.toList()
    ..sort((a, b) => (b.createdDate ?? DateTime(1970))
        .compareTo(a.createdDate ?? DateTime(1970)));

  RxList<OrderModel> _list(String status) {
    switch (_bucket(status)) {
      case 'Delivered':
        return deliveredOrders;
      case 'Cancelled':
        return cancelledOrders;
      default:
        return pendingOrders;
    }
  }

  Future<void> refreshOrders(String status) => loadOrdersByStatus(status);

  OrderModel? getOrderById(int orderId) => [
        ...pendingOrders,
        ...deliveredOrders,
        ...cancelledOrders
      ].firstWhereOrNull((order) => order.id == orderId);

  void cacheOrder(OrderModel order) {
    if (order.id == null || isClosed) return;
    for (final list in [pendingOrders, deliveredOrders, cancelledOrders]) {
      list.removeWhere((item) => item.id == order.id);
    }
    final list = _list(order.deliveryStatus ?? 'Pending');
    list.assignAll(_sorted([...list, order]));
  }

  Future<OrderModel?> fetchOrder(int orderId) async {
    final order = await OrderService.getOrderDetails(orderId);
    if (order != null) cacheOrder(order);
    return order;
  }

  void _setLoading(String status, bool loading) {
    switch (_bucket(status)) {
      case 'Pending':
        isPendingLoading.value = loading;
        break;
      case 'Delivered':
        isDeliveredLoading.value = loading;
        break;
      case 'Cancelled':
        isCancelledLoading.value = loading;
        break;
    }
  }

  void _setError(String status, String error) {
    switch (_bucket(status)) {
      case 'Pending':
        pendingError.value = error;
        break;
      case 'Delivered':
        deliveredError.value = error;
        break;
      case 'Cancelled':
        cancelledError.value = error;
        break;
    }
  }

  List<OrderModel> getOrdersByStatus(String status) {
    switch (status) {
      case 'Pending':
      case 'Shipped':
        return pendingOrders;
      case 'Delivered':
        return deliveredOrders;
      case 'Cancelled':
        return cancelledOrders;
      default:
        return [];
    }
  }

  bool isLoadingByStatus(String status) {
    switch (status) {
      case 'Pending':
      case 'Shipped':
        return isPendingLoading.value;
      case 'Delivered':
        return isDeliveredLoading.value;
      case 'Cancelled':
        return isCancelledLoading.value;
      default:
        return false;
    }
  }

  String getErrorByStatus(String status) {
    switch (status) {
      case 'Pending':
      case 'Shipped':
        return pendingError.value;
      case 'Delivered':
        return deliveredError.value;
      case 'Cancelled':
        return cancelledError.value;
      default:
        return '';
    }
  }
}
