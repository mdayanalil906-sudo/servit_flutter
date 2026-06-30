class AIService {
  static const Map<String, String> _responses = {
    'booking':
        'Your booking is managed in the Bookings section. You can view status, track your expert, or chat with them.',
    'order':
        'Your orders are listed in the Orders section. Each order shows status and customer details.',
    'payment':
        'Payments are processed securely through Razorpay. Membership plans are ₹149/month.',
    'price':
        'Expert pricing varies by category and experience. Check expert profiles for price ranges.',
    'expert':
        'You can browse experts by category or search for specific services from the home screen.',
    'service':
        'SERVIT offers a wide range of home services. Browse categories to find what you need.',
    'account':
        'Your account settings are available in Profile. You can edit details, manage membership, and more.',
    'profile':
        'Go to Profile to edit your information, upload a photo, and manage your account settings.',
    'password':
        'You can reset your password from the login screen by tapping Forgot Password.',
    'verify':
        'Expert verification requires ID proof submission. Go to Profile > Verification to start the process.',
    'refund':
        'For refund-related queries, please describe your issue and it will be escalated to our support team.',
    'cancel':
        'Cancellation policies vary by booking status. Pending bookings can be cancelled free.',
    'complaint':
        'We are sorry to hear that. Your complaint has been noted and will be reviewed by our team.',
    'fraud':
        'Please report any fraudulent activity immediately. Your concern has been escalated to our security team.',
    'chargeback':
        'Chargeback requests are handled by our finance team. Your request has been escalated.',
    'commission':
        'Commission rates and payout details can be found in your expert profile settings.',
    'payout':
        'Payouts are processed based on completed bookings. Contact support for payout schedule details.',
    'membership':
        'Master Membership (₹149/month) gives premium benefits. Elite Membership is for experts.',
    'hello': 'Hello! How can I help you today?',
    'hi': 'Hi there! Feel free to ask me anything about SERVIT.',
    'help': 'I\'m here to help! You can ask about bookings, payments, profiles, or any other feature.',
  };

  static const List<String> _escalatedTopics = [
    'refund',
    'cancel',
    'complaint',
    'fraud',
    'chargeback',
  ];

  static Map<String, dynamic> getResponse(String message) {
    final msg = message.toLowerCase();
    String matched = '';
    for (final entry in _responses.entries) {
      if (msg.contains(entry.key)) {
        matched = entry.value;
        break;
      }
    }
    if (matched.isEmpty) {
      matched =
          'Thank you for your message. If you need help with a specific feature, please mention it and I\'ll assist you.';
    }
    final needsEscalation =
        _escalatedTopics.any((t) => msg.contains(t));
    return {
      'text': matched,
      'escalated': needsEscalation,
    };
  }
}
