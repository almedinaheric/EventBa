/// Application Configuration
/// Contains API endpoints, Stripe keys, and other configuration values

class AppConfig {
  // API Base URL
  static const String apiBaseUrl = "http://localhost:5187/";

  // Stripe Configuration
  // IMPORTANT: Replace these with your actual Stripe keys
  // Get your keys from: https://dashboard.stripe.com/test/apikeys
  static const String stripePublishableKey =
      'pk_test_your_stripe_publishable_key';

  // NOTE: The Stripe Secret Key should NEVER be in the mobile app
  // It should only be on your backend server (appsettings.json)

  // App Settings
  static const String appName = 'EventBa';
  static const String defaultCurrency = 'USD';

  // Feature Flags
  static const bool enableStripePayments = true;
  static const bool enableAnalytics = false;
}
