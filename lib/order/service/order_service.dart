import 'dart:convert';

import '../../base/utils/my_request.dart';
import '../models/order_model.dart';

class OrderService {
  static Future<int?> requestHelp(int orderId, String message) async {
    final response = await MyRequest(
      'orders/single/$orderId/support/',
      {'message': message},
    ).init(showToast: false).postApi();
    return response == null ? null : jsonDecode(response)['id'] as int?;
  }

  static Future<Map<String, dynamic>?> buyAgain(int orderId) async {
    final response = await MyRequest('orders/single/$orderId/buy-again/')
        .init(showToast: false)
        .postApi();
    return response == null
        ? null
        : jsonDecode(response) as Map<String, dynamic>;
  }

  static Future<List<OrderModel>?> getOrdersByStatus(String status) async {
    try {
      String? response = await MyRequest('orders/me/?status=$status')
          .init(showToast: false)
          .getApi();

      if (response != null) {
        List<dynamic> ordersJson = jsonDecode(response);
        return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error fetching orders: $e');
      return null;
    }
  }

  static Future<OrderModel?> getOrderDetails(int orderId) async {
    try {
      String? response = await MyRequest('orders/single/$orderId/')
          .init(showToast: false)
          .getApi();

      if (response != null) {
        Map<String, dynamic> orderJson = jsonDecode(response);
        return OrderModel.fromJson(orderJson);
      }
      return null;
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }
}
