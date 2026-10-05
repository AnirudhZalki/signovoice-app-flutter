import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/subscription/data/razorpay_options.dart';

void main() {
  test('checkout options: UPI first, default blocks kept, prefill only when known, no secrets', () {
    final o = razorpayBaseOptions(description: 'Premium', email: 'a@b.com', name: 'Asha');
    expect(o['description'], 'Premium');
    final display = ((o['config']! as Map)['display']) as Map;
    expect(display['sequence'], ['block.upi']);
    expect((display['preferences'] as Map)['show_default_blocks'], isTrue);
    expect(o['prefill'], {'email': 'a@b.com', 'name': 'Asha'}); // no contact => key omitted
    expect(razorpayBaseOptions().containsKey('prefill'), isFalse);
    expect(o.keys.any((k) => k.toLowerCase().contains('secret')), isFalse);
  });
}
