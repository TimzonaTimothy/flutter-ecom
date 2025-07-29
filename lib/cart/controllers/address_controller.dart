import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';

import '../../base/utils/my_request.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get to => Get.find();

  var addresses = <AddressModel>[].obs;
  var isLoading = false.obs;
  var selectedAddress = Rxn<AddressModel>();
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  /// Fetch all user addresses
  Future<bool> fetchAddresses() async {
    try {
      isLoading.value = true;
      _errorMessage = null;

      log('Fetching user addresses...');

      final response = await MyRequest(
        'address/addresslist/',
        {},
        true, // auth required
        200, // success code
      ).getApi();

      if (response != null) {
        log('Addresses response: $response');

        final List<dynamic> jsonList = jsonDecode(response);
        addresses.value = jsonList.map((json) => AddressModel.fromJson(json)).toList();

        // Set default address as selected
        final defaultAddress = addresses.firstWhereOrNull((addr) => addr.isDefault);
        if (defaultAddress != null) {
          selectedAddress.value = defaultAddress;
        } else if (addresses.isNotEmpty) {
          selectedAddress.value = addresses.first;
        }

        log('Successfully fetched ${addresses.length} addresses');
        isLoading.value = false;
        return true;
      } else {
        _errorMessage = 'Failed to fetch addresses';
        log('Failed to fetch addresses: response is null');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching addresses: $e';
      log('Error fetching addresses: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Get default address
  Future<AddressModel?> getDefaultAddress() async {
    try {
      log('Fetching default address...');

      final response = await MyRequest(
        'address/default/',
        {},
        true, // auth required
        200, // success code
      ).getApi();

      if (response != null) {
        log('Default address response: $response');
        final json = jsonDecode(response);
        return AddressModel.fromJson(json);
      } else {
        log('No default address found');
        return null;
      }
    } catch (e) {
      log('Error fetching default address: $e');
      return null;
    }
  }

  /// Add new address
  Future<bool> addAddress(CreateAddressModel addressData) async {
    try {
      isLoading.value = true;
      _errorMessage = null;

      log('Adding new address: ${addressData.toJson()}');

      final response = await MyRequest(
        'address/add/',
        addressData.toJson(),
        true, // auth required
        201, // created status code
      ).postApi();

      if (response != null) {
        log('Address added successfully');
        await fetchAddresses(); // Refresh addresses
        return true;
      } else {
        _errorMessage = 'Failed to add address';
        log('Failed to add address: response is null');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding address: $e';
      log('Error adding address: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Set address as default
  Future<bool> setDefaultAddress(int addressId) async {
    try {
      log('Setting default address: $addressId');

      final response = await MyRequest(
        'address/set-default/?id=$addressId',
        {},
        true, // auth required
        200, // success code
      ).patchApi();

      if (response != null) {
        log('Default address set successfully');
        
        // Update local state
        // for (var address in addresses) {
        //   address = address.copyWith(isDefault: address.id == addressId);
        // }
        addresses.value = addresses.map((addr) {
  return addr.copyWith(isDefault: addr.id == addressId);
}).toList();
addresses.refresh();
        
        // Update selected address
        final newDefault = addresses.firstWhereOrNull((addr) => addr.id == addressId);
        if (newDefault != null) {
          selectedAddress.value = newDefault.copyWith(isDefault: true);
        }
        
        addresses.refresh();
        return true;
      } else {
        _errorMessage = 'Failed to set default address';
        log('Failed to set default address: response is null');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error setting default address: $e';
      log('Error setting default address: $e');
      return false;
    }
  }

  /// Delete address
  Future<bool> deleteAddress(int addressId) async {
    try {
      log('Deleting address: $addressId');

      final response = await MyRequest(
        'address/delete/?id=$addressId',
        {},
        true, // auth required
        200, // success code
      ).deleteApi();

      if (response != null) {
        log('Address deleted successfully');
        await fetchAddresses(); // Refresh addresses
        return true;
      } else {
        _errorMessage = 'Failed to delete address';
        log('Failed to delete address: response is null');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting address: $e';
      log('Error deleting address: $e');
      return false;
    }
  }

  /// Select address (for checkout)
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  /// Clear addresses (for logout)
  void clearAddresses() {
    addresses.clear();
    selectedAddress.value = null;
    _errorMessage = null;
    isLoading.value = false;
  }
}