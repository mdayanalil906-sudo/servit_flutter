class Constants {
  static const List<String> staticScreens = [
    'role',
    'userLogin',
    'userRegister',
    'userRegisterStep2',
    'expertLogin',
    'expertRegister',
    'expertRegisterStep2',
    'forgotPassword',
    'forgotPasswordSent',
    'privacyPolicy',
    'termsConditions',
    'expertPrivacy',
    'expertTerms',
  ];

  static const Map<String, List<String>> preloadMap = {
    'userHome': ['userBookings', 'userAlerts', 'userProfile'],
    'userBookings': ['userHome', 'userAlerts', 'userProfile'],
    'userAlerts': ['userHome', 'userBookings', 'userProfile'],
    'userProfile': ['userHome', 'userSettings', 'userBookings'],
    'expertHome': ['expertOrders', 'expertAlerts', 'expertProfile'],
    'searchResults': ['expertDetail'],
    'expertDetail': ['bookingForm'],
  };

  static const List<String> bookingStatuses = [
    'pending',
    'active',
    'completed',
    'cancelled',
  ];

  static const List<Map<String, dynamic>> faqs = [
    {'q': 'How do I book an expert?', 'a': 'Go to home, search for a category or expert, tap on their profile, then tap Book Now.'},
    {'q': 'Can I cancel a booking?', 'a': 'Yes, pending bookings can be cancelled free. Active bookings may have a ₹25 cancellation fee.'},
    {'q': 'How do I become an expert?', 'a': 'Select Expert role on the role selection screen and complete registration with your details.'},
    {'q': 'What is Master Membership?', 'a': 'Master Membership gives premium benefits at ₹149/month with exclusive discounts and priority service.'},
    {'q': 'How do I track my expert?', 'a': 'Open your active booking and tap the Track button to see the expert\'s live location.'},
    {'q': 'How do I pay?', 'a': 'Pay online via Razorpay or choose Cash on Service. Membership and cancellation fees require online payment.'},
    {'q': 'How do I contact support?', 'a': 'Go to Help & Support from your profile menu and start a chat.'},
    {'q': 'Can I change my address?', 'a': 'Yes, you can update your address and location from Edit Profile or during booking.'},
    {'q': 'How are ratings calculated?', 'a': 'Ratings are based on customer feedback after each completed booking.'},
    {'q': 'How do I reset my password?', 'a': 'Tap Forgot Password on the login screen and enter your registered email.'},
  ];

  static const List<Map<String, dynamic>> expertFaqs = [
    {'q': 'How do I get new orders?', 'a': 'Keep your profile updated and stay online. Customers find you through search and categories.'},
    {'q': 'How do I accept a booking?', 'a': 'Go to Orders, tap on a pending order, and tap Accept.'},
    {'q': 'What is Elite Membership?', 'a': 'Elite Membership gives premium benefits at ₹149/month including waived cancellation fees.'},
    {'q': 'How does verification work?', 'a': 'Submit your ID proof from the Profile > Verification section. Admin will review and approve.'},
    {'q': 'How do I get paid?', 'a': 'Payments are processed through the platform. Contact support for payout details.'},
  ];
}
