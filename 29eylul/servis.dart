void main() {
  final bool isProduction = true;
  final Set<String> cloudServices = {
    'auth-service',
    'payment-api',
    'notification-service',
    'auth-service',
  };

  final List<String> allServices = [
    ...cloudServices,
    if (isProduction) 'vault-secret-manager',
  ];

  print("Servis Listesi: $allServices");
}
