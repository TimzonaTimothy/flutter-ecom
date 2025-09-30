# Flutter E-Commerce App

A full-featured Flutter e-commerce mobile application with Django REST API backend integration. This app provides a complete shopping experience with multiple payment gateways, real-time notifications, and comprehensive order management.

## 📱 Features

### Authentication & Authorization
- **User Registration** with email verification (OTP)
- **Login/Logout** with JWT authentication
- **Remember Me** functionality
- **Password Reset** via email
- **Forgot Password** flow
- **Token Auto-Refresh** mechanism
- Account activation via OTP

### Product Management
- **Product Listing** with pagination
- **Category-based Filtering**
- **Brand Filtering**
- **Advanced Search** functionality
- **Multi-criteria Filters** (price, rating, gender, newest, popular)
- **Product Details** with image gallery
- **Product Reviews & Ratings** (add, edit, view)
- **Related Products** suggestions

### Shopping Experience
- **Shopping Cart** with real-time updates
- **Optimistic UI Updates** for cart operations
- **Wishlist Management**
- **Multiple Address Management**
- **Set Default Address**
- **Location Selection**

### Orders & Payments
- **Order Creation** with address validation
- **Order History** (Pending, Shipped, Delivered, Cancelled)
- **Order Details** with product breakdown
- **Order Tracking**
- **Multiple Payment Gateways:**
  - PayStack
  - Flutterwave
  - Stripe
- **WebView Payment Integration**
- **Payment Verification**
- **Payment Success/Failure Handling**

### User Interface
- **Onboarding Screens**
- **Splash Screen**
- **Bottom Navigation Bar** with badges
- **Pull-to-Refresh** functionality
- **Shimmer Loading Effects**
- **Image Sliders** for promotions
- **Category Scroller**
- **Product Grid/List Views**
- **Filter Chips**
- **Responsive Design**

### Notifications
- **Push Notifications** integration
- **In-App Notifications**
- **Notification Badge Counter**
- **Mark as Read** functionality

### Profile Management
- **User Profile** view and edit
- **Address Management** (add, edit, delete, set default)
- **Order History**
- **Wishlist Access**
- **Logout**

## 🏗️ Architecture

### State Management
- **GetX** for state management and dependency injection
- Reactive programming with observables
- Controllers for business logic separation

### Network Layer
- Custom `MyRequest` class for API calls
- Automatic token refresh on 401 errors
- Error handling with user-friendly messages
- Request timeout management (60 seconds)
- Support for GET, POST, PUT, PATCH, DELETE
- Multipart file upload support

### Authentication Flow
- JWT-based authentication
- Access & Refresh token management
- Token expiry tracking
- Automatic token refresh timer (55 minutes)
- Remember Me with SharedPreferences
- Secure token storage


## 🔧 Project Structure

```
lib/
├── auth/
│   ├── controllers/
│   │   ├── login_controller.dart
│   │   ├── register_controller.dart
│   │   ├── otp_controller.dart
│   │   └── password_controller.dart
│   ├── service/
│   │   └── auth_service.dart
│   └── views/
│       ├── sign_in.dart
│       ├── sign_up.dart
│       ├── sign_up_otp_code.dart
│       ├── forgot_password.dart
│       └── reset_password.dart
│
├── products/
│   ├── controllers/
│   │   ├── product_controller.dart
│   │   ├── category_controller.dart
│   │   └── review_controller.dart
│   ├── models/
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   └── review_model.dart
│   ├── service/
│   │   ├── product_service.dart
│   │   └── review_service.dart
│   └── views/
│       ├── product_detail.dart
│       ├── product_list_by_category.dart
│       ├── product_search_screen.dart
│       ├── product_filter.dart
│       └── category_list.dart
│
├── cart/
│   ├── controllers/
│   │   ├── cart_controller.dart
│   │   └── address_controller.dart
│   ├── models/
│   │   ├── cart_model.dart
│   │   ├── create_cart_model.dart
│   │   └── address_model.dart
│   └── views/
│       ├── cart_screen.dart
│       └── checkout_screen.dart
│
├── wishlist/
│   ├── controllers/
│   │   └── wishlist_controller.dart
│   ├── models/
│   │   └── wishlist_model.dart
│   └── views/
│       └── wishlist.dart
│
├── orders/
│   ├── controllers/
│   │   └── order_controller.dart
│   ├── models/
│   │   └── order_model.dart
│   ├── service/
│   │   └── order_service.dart
│   └── views/
│       ├── order_screen.dart
│       └── order_detail.dart
│
├── payment/
│   ├── controllers/
│   │   └── payment_controller.dart
│   ├── models/
│   │   └── payment_request_model.dart
│   └── views/
│       ├── payment_method_screen.dart
│       ├── payment_webview.dart
│       └── payment_success_screen.dart
│
├── notification/
│   ├── controllers/
│   │   └── notification_controller.dart
│   └── views/
│       └── notification_screen.dart
│
├── profile/
│   └── views/
│       └── profile_screen.dart
│
├── home/
│   └── views/
│       ├── home_screen.dart
│       └── location_screen.dart
│
├── onboarding/
│   └── views/
│       ├── splash_screen.dart
│       └── welcome_screen.dart
│
├── base/
│   ├── res/
│   │   ├── base_url.dart
│   │   ├── media.dart
│   │   └── styles/
│   │       └── app_styles.dart
│   ├── utils/
│   │   ├── my_request.dart
│   │   ├── snackbar.dart
│   │   └── token.dart
│   └── widgets/
│       ├── app_double_text.dart
│       ├── category_scroller.dart
│       ├── category_shimmer.dart
│       ├── filter_card.dart
│       ├── image_sliders.dart
│       ├── product_card.dart
│       └── product_shimmer.dart
│
└── bottom_nav_bar.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Django backend API running

### Backend Requirements
The app requires a Django REST API with the following endpoints:

#### Authentication
- `POST /auth/users/` - User registration
- `POST /auth/login/` - User login
- `POST /auth/activate-otp/` - OTP verification
- `POST /auth/resend-otp/` - Resend OTP
- `POST /auth/jwt/refresh/` - Token refresh
- `POST /auth/jwt/verify/` - Token verification
- `POST /auth/password/reset/` - Password reset request
- `POST /auth/password/reset/confirm/` - Password reset confirmation

#### Products
- `GET /products/` - Get all products
- `GET /products/{id}/` - Get product details
- `GET /products/category/{id}/` - Get products by category
- `GET /products/search/` - Search products

#### Cart
- `GET /cart/me/` - Get user cart
- `POST /cart/add/` - Add to cart
- `PATCH /cart/update/{id}/` - Update cart item
- `DELETE /cart/delete/{id}/` - Remove from cart
- `DELETE /cart/clear/` - Clear cart

#### Wishlist
- `GET /wishlist/me/` - Get user wishlist
- `POST /wishlist/add/` - Add to wishlist
- `DELETE /wishlist/remove/{id}/` - Remove from wishlist

#### Orders
- `POST /orders/add/` - Create order
- `GET /orders/status/{status}/` - Get orders by status
- `GET /orders/{id}/` - Get order details

#### Payments
- `POST /payments/initiate-paystack-payment/` - Initiate PayStack payment
- `GET /payments/verify-paystack-payment/{reference}/` - Verify PayStack payment
- `POST /payments/initiate-flutterwave-payment/` - Initiate Flutterwave payment
- `GET /payments/verify-flutterwave-payment/{reference}/` - Verify Flutterwave payment
- `POST /payments/initiate-stripe-payment/` - Initiate Stripe payment
- `GET /payments/verify-stripe-payment/{session_id}/` - Verify Stripe payment

#### Address
- `GET /address/addresslist/` - Get user addresses
- `POST /address/add/` - Add address
- `PATCH /address/set-default/?id={id}` - Set default address
- `DELETE /address/delete/?id={id}` - Delete address

#### Notifications
- `GET /notifications/` - Get user notifications
- `PATCH /notifications/mark-read/{id}/` - Mark notification as read

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ecom_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure base URL:
   - Navigate to `lib/base/res/base_url.dart`
   - Update the `baseUrl` constant with your Django API URL:
   ```dart
   const String baseUrl = 'https://your-api-url.com';
   ```

4. Run the app:
```bash
flutter run
```

## 🔑 Key Features Implementation

### Token Refresh Mechanism
The app implements automatic token refresh:
- Tokens are checked every 55 minutes
- On 401 errors, tokens are automatically refreshed
- If refresh fails, user is logged out
- Remember Me option stores refresh token persistently

### Optimistic UI Updates
Cart and wishlist operations use optimistic updates:
- UI updates immediately on user action
- Changes are rolled back if API call fails
- Provides smooth user experience

### Payment Flow
1. User selects payment method (PayStack/Flutterwave/Stripe)
2. Order is created on backend
3. Payment gateway session is initiated
4. User is redirected to WebView for payment
5. Payment is verified on callback
6. Order status is updated
7. User sees success screen with order details

### Error Handling
- Network errors show "Check your internet" message
- Timeout errors (60s) show appropriate message
- API errors display server-provided error messages
- Validation errors are shown inline

## 📱 Screens

### Public Screens
- Splash Screen
- Onboarding/Welcome Screen
- Sign In
- Sign Up
- OTP Verification
- Forgot Password
- Reset Password

### Protected Screens
- Home (with categories, products, search)
- Product Details
- Product List (by category/filter)
- Search Results
- Cart
- Checkout
- Wishlist
- Orders (Pending/Delivered/Cancelled)
- Order Details
- Payment Selection
- Payment WebView
- Payment Success
- Notifications
- Profile
- Address Management
- Location Selection

## 🎨 UI Components

### Reusable Widgets
- `ProductCard` - Product display card
- `CategoryScroller` - Horizontal category list
- `FilterCard` - Filter chips
- `AppDoubleText` - Section header with "View All"
- `ImageSliders` - Banner carousel
- Shimmer loading placeholders

### Bottom Navigation
- Home
- Wishlist (with badge)
- Cart (with badge)
- Profile

## 🔒 Security Features

- JWT token authentication
- Secure token storage using SharedPreferences
- Automatic token refresh
- Session expiry handling
- Form validation
- OTP verification for account activation
- Password reset via email

## 📊 State Management

Controllers manage:
- Loading states (`isLoading`, `isLoad`)
- Error messages (`errorMessage`)
- Data lists (products, cart items, orders, etc.)
- Selected items (address, filters)
- Form state (rating, review text)

## 🧪 Testing Considerations

To test the app:
1. Ensure Django backend is running
2. Configure correct `baseUrl`
3. Test authentication flow (register → OTP → login)
4. Test cart operations with optimistic updates
5. Test payment gateways (use test credentials)
6. Test token refresh by waiting 55+ minutes
7. Test offline behavior

## 🐛 Known Issues & Limitations

- Payment gateway test credentials required
- Push notifications require Firebase setup
- Image uploads limited to specific formats
- No offline data caching (requires internet)

## 📄 License

This project is part of a commercial application. All rights reserved.

## 👥 Contributors

Developed by Arinze Timothy

