import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/res/styles/app_styles.dart';
import '../../base/utils/location.dart';
import '../../base/utils/snackbar.dart';
import '../../base/widgets/primary_button.dart';
import '../../base/widgets/primary_input.dart';
import '../controllers/address_controller.dart';
import '../models/address_model.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  late AddressController addressController;

  @override
  void initState() {
    super.initState();
    addressController = Get.find<AddressController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text("Shipping Address", style: AppStyles.headLineStyle2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (addressController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppStyles.primaryColor,
                  ),
                );
              }

              if (addressController.addresses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 80,
                        color: AppStyles.whiteSmokeColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No addresses found",
                        style: AppStyles.headLineStyle3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add your first shipping address",
                        style: AppStyles.textStyle.copyWith(
                          color: AppStyles.whiteSmokeColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppStyles.primaryColor,
                onRefresh: () => addressController.fetchAddresses(),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: addressController.addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final address = addressController.addresses[index];
                    final isSelected =
                        addressController.selectedAddress.value?.id ==
                            address.id;

                    return Dismissible(
                      key: Key(address.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        // Show confirmation dialog before deletion
                        return await _showDeleteConfirmation(address);
                      },
                      onDismissed: (direction) async {
                        // Handle deletion after confirmation
                        if (address.id != null) {
                          final success = await addressController
                              .deleteAddress(address.id!);
                          if (success) {
                            showSuccessSnackbar("Address deleted successfully");
                          } else {
                            showFailureSnackbar(
                              addressController.errorMessage ??
                                  "Failed to delete address",
                            );
                          }
                        }
                      },
                      child: AddressCard(
                        address: address,
                        selectedId: addressController.selectedAddress.value?.id,
                        onTap: () {
                          addressController.selectAddress(address);
                        },
                        onSetDefault: () async {
                          if (!address.isDefault && address.id != null) {
                            final success = await addressController
                                .setDefaultAddress(address.id!);
                            if (success) {
                              showSuccessSnackbar("Default address updated");
                            } else {
                              showFailureSnackbar(
                                  addressController.errorMessage ??
                                      "Failed to set default address");
                            }
                          }
                        },
                        onDelete: () async {
                          if (address.id != null) {
                            final confirmed =
                                await _showDeleteConfirmation(address);
                            if (confirmed && address.id != null) {
                              final success = await addressController
                                  .deleteAddress(address.id!);
                              if (success) {
                                showSuccessSnackbar(
                                    "Address deleted successfully");
                              } else {
                                showFailureSnackbar(
                                    addressController.errorMessage ??
                                        "Failed to delete address");
                              }
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: DottedBorder(
              color: AppStyles.primaryColor,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              dashPattern: const [6, 3],
              strokeWidth: 1.5,
              child: OutlinedButton.icon(
                // onPressed: () async {
                //   final result = await Get.to(
                //     const AddAddressScreen(),

                //     transition: Transition.rightToLeftWithFade,
                //     duration: const Duration(milliseconds: 500),
                //   );

                //   if (result == true) {
                //     await addressController.fetchAddresses();
                //   }
                // },
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => const AddAddressForm(),
                  );

                  if (result == true) {
                    await addressController.fetchAddresses();
                  }
                },

                icon: Icon(Icons.add, color: AppStyles.primaryColor),
                label: Text(
                  "Add New Shipping Address",
                  style: TextStyle(color: AppStyles.primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: PrimaryButton(
                verticalPadding: 10,
                horizontalPadding: 100,
                text: 'Apply',
                // onTap: () {
                //   if (addressController.selectedAddress.value != null) {
                //     Get.back(result: true);
                //   } else {
                //     showFailureSnackbar("Please select an address");
                //   }
                // },
                onTap: () async {
                  final selected = addressController.selectedAddress.value;

                  if (selected != null) {
                    if (!selected.isDefault && selected.id != null) {
                      final success = await addressController
                          .setDefaultAddress(selected.id!);
                      if (success) {
                        showSuccessSnackbar("Default address updated");
                      } else {
                        showFailureSnackbar(addressController.errorMessage ??
                            "Failed to set default address");
                        return;
                      }
                    }

                    Get.back(result: true); // Close the screen after success
                  } else {
                    showFailureSnackbar("Please select an address");
                  }
                }),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(AddressModel address) async {
    if (address.isDefault) {
      showFailureSnackbar("Cannot delete default address");
      return false;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppStyles.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text("Delete Address"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Are you sure you want to delete this address?"),
              const SizedBox(height: 8),
              Text(
                "${address.displayAddressType}: ${address.address}",
                style: AppStyles.textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: AppStyles.textStyle.copyWith(
                  color: AppStyles.primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Delete",
                style: AppStyles.textStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirm ?? false;
  }
}

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final int? selectedId;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.selectedId,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedId == address.id;
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? AppStyles.primaryColor
                  : AppStyles.whiteSmokeColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppStyles.primaryColor.withOpacity(0.05) : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_pin,
                    color: AppStyles.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.displayAddressType,
                              style: AppStyles.headLineStyle3,
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppStyles.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Default",
                                  style: AppStyles.textStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Address: ${address.address}",
                          style: AppStyles.textStyle.copyWith(
                            color: AppStyles.whiteSmokeColor,
                          ),
                        ),
                        Text(
                          "Phone: ${address.phone}",
                          style: AppStyles.textStyle.copyWith(
                            color: AppStyles.whiteSmokeColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<int>(
                    value: address.id!,
                    groupValue: selectedId,
                    onChanged: (_) => onTap(),
                    activeColor: AppStyles.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class AddAddressForm extends StatefulWidget {
  const AddAddressForm({super.key});

  @override
  State<AddAddressForm> createState() => _AddAddressFormState();
}

class _AddAddressFormState extends State<AddAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  final AddressController addressController = Get.find();

  @override
  void dispose() {
    _addressTypeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
          .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add New Address", style: AppStyles.headLineStyle2),
              const SizedBox(height: 20),
              PrimaryInput(
                validator: (value) => value!.isEmpty ? "Required" : null,
                controller: _addressTypeController,
                hintText: "Address Type (e.g. Home, Office)",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              PrimaryInput(
                validator: (value) => value!.isEmpty ? "Required" : null,
                controller: _addressController,
                hintText: "Full Address",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              PrimaryInput(
                validator: (value) => value!.isEmpty ? "Required" : null,
                controller: _phoneController,
                hintText: "Phone",
                obscureText: false,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    activeColor: AppStyles.primaryColor,
                    checkColor: AppStyles.whiteColor,
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() => _isDefault = value ?? false);
                    },
                  ),
                  const Text("Set as default address"),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() {
                return addressController.isLoading.value
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
                        horizontalPadding: 20,
                        text: "Save Address",
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final newAddress = CreateAddressModel(
                              lat:
                                  0.0, // Or use actual location data if available
                              lng: 0.0,
                              isDefault: _isDefault,
                              address: _addressController.text,
                              phone: _phoneController.text,
                              addressType:
                                  _addressTypeController.text.toLowerCase(),
                            );

                            final success =
                                await addressController.addAddress(newAddress);

                            if (success) {
                              showSuccessSnackbar("Address added!");
                              Navigator.pop(context, true);
                            } else {
                              showFailureSnackbar(
                                  addressController.errorMessage ??
                                      "Failed to add address");
                            }
                          }
                        },
                      );
              }),
              const SizedBox(height: 10),
              Obx(() {
                return addressController.isLoading.value
                    ? const CircularProgressIndicator()
                    : PrimaryButton(
                        isBorder: true,
                        backgroundColor: AppStyles.bgColor,
                        textColor: AppStyles.primaryColor,
                        horizontalPadding: 20,
                        text: "Use Current Location",
                        onTap: () async {
                          final locationData = await getCurrentLocationData();
                          if (locationData != null) {
                            final addressModel = CreateAddressModel(
                              lat: locationData['lat'],
                              lng: locationData['lng'],
                              isDefault: true,
                              address: locationData['address'],
                              phone: '0000000000', // Replace with user phone
                              addressType: 'home',
                            );

                            bool success = await addressController
                                .addAddress(addressModel);

                            if (success) {
                              showSuccessSnackbar("Address added!");
                              Navigator.pop(context, true);
                            } else {
                              showFailureSnackbar(
                                  addressController.errorMessage ??
                                      "Failed to add address");
                            }
                          } else {
                            Get.snackbar("Location Error",
                                "Could not get current location");
                          }
                        },
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
