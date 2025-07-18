import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ecom_app/base/utils/snackbar.dart';
import 'package:ecom_app/base/utils/token.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../res/base_url.dart';

const fullUrl = baseUrl;
const baseURLGeneral = fullUrl;

class MyRequest {
  String path;
  Map body;

  bool auth;
  int successCode;
  String baseURL;
  bool showToast = true;
  http.Response? returnResponseEvenOnError;

  MyRequest(
    this.path, [
    this.body = const {},
    this.auth = true,
    this.successCode = 200,
    this.baseURL = baseURLGeneral,
  ]);

  MyRequest init({
    bool showToast = true,
  }) {
    this.showToast = showToast;
    return this;
  }

  static const int timeoutTime = 60;

  Future<bool> refreshAccessToken() async {
    try {
      String? authToken = getRefreshToken();
      // change this to the endpoint to get refresh token
      final response = await http
          .post(
            Uri.parse('$baseURL/auth/jwt/refresh/'),
            body: jsonEncode({"refresh": authToken ?? ""}),
          )
          .timeout(const Duration(seconds: timeoutTime));

      log('refresh_token response ${response.body}');

      Map resp = jsonDecode(response.body);
      if (response.statusCode != 200) {
        return false;
      }

      // todo, check the response
      saveTokens(resp['access_token'], authToken!);

      return true;
    } catch (e) {
      return false;
    }
  }

  http.Response? returnResponse() {
    return returnResponseEvenOnError;
  }

  Future<String?> parse(http.Response response, bool auth, String method,
      [int successCode = 200]) async {
    // set to the current response
    returnResponseEvenOnError = response;

    if (response.statusCode != successCode) {
      // not success
      String message = jsonDecode(response.body)['detail'] ?? "";
      if (showToast && (response.statusCode != 401)) {
        // showFailureSnackbar(message);
        showFailureSnackbar(
          message,
        );
      }

      if (auth && response.statusCode == 401) {
        // refetch the access token and try again
        bool refetchResp = await refreshAccessToken();
        if (refetchResp) {
          method = method.toLowerCase();
          if (method == "post") {
            postApi();
          } else if (method == "get") {
            getApi();
          } else if (method == "put") {
            putApi();
          } else if (method == "patch") {
            patchApi();
          } else if (method == "delete") {
            deleteApi();
          } else {}
        } else {
          if (showToast) {
            // showFailureSnackbar(
            //     'Session expired please login again');
            showFailureSnackbar(
              'Session expired please login again',
            );
          }
          removeToken();
          // await UserController.instance.removeUser();
          // toLogin();
          return null;
        }
      }
      return null;
    }
    return response.body;
  }

  Future<String?> postApi() async {
    try {
      String? authToken = getToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (auth) 'Authorization': 'Bearer $authToken',
      };
      log('body: $body');
      log(Uri.parse('$baseURL/$path').toString());

      final response = await http
          .post(
            Uri.parse('$baseURL/$path'),
            body: jsonEncode(body),
            headers: headers,
          )
          .timeout(const Duration(seconds: timeoutTime));

      log('response body: ${response.body}');
      log('status: ${response.statusCode.toString()}');

      return parse(response, auth, 'post', successCode);
    } on SocketException {
      if (showToast) {
        // showFailureSnackbar("Check your internet");
        showFailureSnackbar(
          "Check your internet",
        );
      }
    } on TimeoutException {
      if (showToast) {
        showFailureSnackbar("Request timed out");
      }
    } catch (e) {
      if (showToast) {
        showFailureSnackbar("Something went wrong");
      }
    }
    return null;
  }

  Future<String?> getApi() async {
    try {
      String? authToken = getToken();
      Map<String, String> headers = {'Authorization': 'Bearer $authToken'};

      log('body: $body');
      log(Uri.parse('$baseURL/$path').toString());

      final response = await http
          .get(Uri.parse('$baseURL/$path'), headers: auth ? headers : null)
          .timeout(const Duration(seconds: timeoutTime));

      log('response body: ${response.body}');
      log('status: ${response.statusCode.toString()}');

      return parse(response, auth, 'get');
    } on SocketException {
      if (showToast) {
        showFailureSnackbar("Check your internet");
      }
    } on TimeoutException {
      if (showToast) {
        showFailureSnackbar("Request timed out");
      }
    } catch (e) {
      if (showToast) {
        showFailureSnackbar("Something went wrong");
      }
    }
    return null;
  }

  Future<String?> putApi() async {
    try {
      String? authToken = getToken();
      Map<String, String> headers = {'Authorization': 'Bearer $authToken'};

      log('body: $body');
      log(Uri.parse('$baseURL/$path').toString());

      final response = await http.put(
        Uri.parse('$baseURL/$path'),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          if (auth) ...headers,
        },
      ).timeout(const Duration(seconds: timeoutTime));

      log('response body: ${response.body}');
      log('status: ${response.statusCode.toString()}');

      return parse(response, auth, 'put');
    } on SocketException {
      if (showToast) {
        showFailureSnackbar("Check your internet");
      }
    } on TimeoutException {
      if (showToast) {
        showFailureSnackbar("Request timed out");
      }
    } catch (e) {
      if (showToast) {
        showFailureSnackbar("Something went wrong");
      }
    }
    return null;
  }

  Future<String?> patchApi() async {
    try {
      String? authToken = getToken();
      Map<String, String> headers = {'Authorization': 'Bearer $authToken'};

      log('body: $body');

      log(Uri.parse('$baseURL/$path').toString());
      final response = await http
          .patch(Uri.parse('$baseURL/$path'),
              body: body, headers: auth ? headers : null)
          .timeout(const Duration(seconds: timeoutTime));

      log('response body: ${response.body}');
      log('status: ${response.statusCode.toString()}');
      return parse(response, auth, 'patch');
    } on SocketException {
      if (showToast) {
        showFailureSnackbar("Check your internet");
      }
    } on TimeoutException {
      if (showToast) {
        showFailureSnackbar("Request timed out");
      }
    } catch (e) {
      if (showToast) {
        showFailureSnackbar("Something went wrong");
      }
    }
    return null;
  }

  Future<String?> deleteApi() async {
    try {
      String? authToken = getToken();
      Map<String, String> headers = {'Authorization': 'Bearer $authToken'};
      final response = await http.delete(
        Uri.parse('$baseURL/$path'),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          if (auth) ...headers,
        },
      ).timeout(const Duration(seconds: timeoutTime));
      return parse(response, auth, 'delete');
    } on SocketException {
      if (showToast) {
        showFailureSnackbar("Check your internet");
      }
    } on TimeoutException {
      if (showToast) {
        showFailureSnackbar("Request timed out");
      }
    } catch (e) {
      if (showToast) {
        showFailureSnackbar("Something went wrong");
      }
    }
    return null;
  }

  Future<http.StreamedResponse> sendFile(XFile image,
      {String fieldName = 'file'}) async {
    log('body: $body');
    log(Uri.parse('$baseURL/$path').toString());

    final url = Uri.parse('$baseURL/$path');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(authHeader());

    request.files.add(http.MultipartFile(
      fieldName,
      image.readAsBytes().asStream(),
      await image.length(),
      filename: 'image.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));

    final http.StreamedResponse response = await request.send();
    // don't call because it is to be called once await response.stream.bytesToString();

    if (response.statusCode == 401) {
      final res = await refreshAccessToken();
      if (!res) {
        removeToken();
        // await UserController.instance.removeUser();
        // toLogin();
      }
    }

    if (response.statusCode != 200) {
      showFailureSnackbar("Upload failed");
    }

    log('status: ${response.statusCode.toString()}');

    return response;
  }
}


String extractErrorMessage(String responseBody) {
  try {
    final json = jsonDecode(responseBody);

    if (json is Map<String, dynamic>) {
      if (json.containsKey('message')) {
        final message = json['message'];
        if (message is List) return message.first.toString(); // <-- ✅ FIX
        return message.toString();
      }
      if (json.containsKey('detail')) return json['detail'].toString();

      final firstKey = json.keys.first;
      final value = json[firstKey];
      if (value is List) return value.first.toString();
      return value.toString();
    }

    return "Unexpected error format.";
  } catch (_) {
    return "Failed to parse error.";
  }
}
