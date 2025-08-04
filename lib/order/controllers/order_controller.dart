import 'package:get/get.dart';
import '../models/order_model.dart';
import '../service/order_service.dart';

class OrderController extends GetxController {
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

  Future<void> loadAllOrders() async {
    await Future.wait([
      loadOrdersByStatus('Pending'),
      loadOrdersByStatus('Shipped'),
      loadOrdersByStatus('Delivered'),
      loadOrdersByStatus('Cancelled'),
    ]);
  }

  Future<void> loadOrdersByStatus(String status) async {
    try {
      _setLoading(status, true);
      _setError(status, '');

      List<OrderModel>? orders = await OrderService.getOrdersByStatus(status);
      print('Fetched ${orders?.length ?? 0} orders for status: $status');

      if (orders != null) {
        _setOrders(status, orders);
      } else {
        _setError(status, 'Failed to load $status orders');
      }
    } catch (e) {
      _setError(status, 'Error loading $status orders: ${e.toString()}');
    } finally {
      _setLoading(status, false);
    }
  }

  Future<void> refreshOrders(String status) async {
    await loadOrdersByStatus(status);
  }

  OrderModel? getOrderById(int orderId) {
    try {
      // Check cached orders first
      OrderModel? order = pendingOrders.firstWhereOrNull((order) => order.id == orderId) ??
          deliveredOrders.firstWhereOrNull((order) => order.id == orderId) ??
          cancelledOrders.firstWhereOrNull((order) => order.id == orderId);

      if (order != null) {
        
        return order;
      }

      return null; // Return null if not found, let FutureBuilder handle API call
    } catch (e) {
      
      return null;
    }
  }

  void _setLoading(String status, bool loading) {
    switch (status) {
      case 'Pending':
      case 'Shipped':
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
    switch (status) {
      case 'Pending':
      case 'Shipped':
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

  void _setOrders(String status, List<OrderModel> orders) {
    switch (status) {
      case 'Pending':
        // Combine Pending orders with existing Shipped orders
        pendingOrders.value = [
          ...orders,
          ...pendingOrders.where((order) => order.deliveryStatus == 'Shipped')
        ];
        break;
      case 'Shipped':
        // Combine Shipped orders with existing Pending orders
        pendingOrders.value = [
          ...orders,
          ...pendingOrders.where((order) => order.deliveryStatus == 'Pending')
        ];
        break;
      case 'Delivered':
        deliveredOrders.value = orders;
        break;
      case 'Cancelled':
        cancelledOrders.value = orders;
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