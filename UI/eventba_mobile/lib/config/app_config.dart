/// Application Configuration
/// Contains API endpoints, Stripe keys, and other configuration values

class AppConfig {
  // API Base URL
  static const String apiBaseUrl = "http://localhost:5187/";

  // Stripe Configuration
  // IMPORTANT: Replace these with your actual Stripe keys
  // Get your keys from: https://dashboard.stripe.com/test/apikeys
  // This key should match the one in backend appsettings.json
  static const String stripePublishableKey =
      'pk_test_51ScDaDRzbkjX8obZ9LK42fHOJFl8OfuzEapVIhAB8cH8RsOhXz4Z99eYpCutbC7q6tWHd1vvuNX3BoAlrcjZsF2V00AKnW5fvA';

  // NOTE: The Stripe Secret Key should NEVER be in the mobile app
  // It should only be on your backend server (appsettings.json)

  // App Settings
  static const String appName = 'EventBa';
  static const String defaultCurrency = 'USD';

  // Feature Flags
  static const bool enableStripePayments = true;
  static const bool enableAnalytics = false;
}
