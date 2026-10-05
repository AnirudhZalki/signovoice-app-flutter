/// Checkout options shared by every Razorpay flow (subscription, one-time order, interpreter session).
/// Follows Razorpay's Android Standard Checkout "payment methods" configuration: UPI first (it carries UPI AutoPay
/// and opens installed UPI apps such as Google Pay / PhonePe / Paytm through intents), then the default blocks
/// (cards, netbanking, wallets).
Map<String, Object?> razorpayBaseOptions({String? description, String? email, String? contact, String? name}) => {
      'name': 'SignoVoice',
      'description': ?description,
      'theme': {'color': '#3157D5'},
      'retry': {'enabled': true, 'max_count': 2},
      'timeout': 900, // seconds the checkout stays open
      'modal': {'confirm_close': true},
      if (email != null || contact != null || name != null)
        'prefill': {
          'email': ?email,
          'contact': ?contact,
          'name': ?name,
        },
      'config': {
        'display': {
          'blocks': {
            'upi': {
              'name': 'Pay via UPI',
              'instruments': [
                {'method': 'upi'},
              ],
            },
          },
          'sequence': ['block.upi'],
          'preferences': {'show_default_blocks': true},
        },
      },
    };
