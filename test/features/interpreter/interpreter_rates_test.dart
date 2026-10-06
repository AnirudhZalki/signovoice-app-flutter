import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/interpreter/domain/interpreter_models.dart';

void main() {
  adminModelTest();
  test('interpreter list item carries the rate; missing rate means free', () {
    final i = Interpreter.fromJson({'id': 'i1', 'name': 'Ravi', 'status': 'available', 'ratePaise': 15000, 'sessionMinutes': 30, 'languages': ['en', 'hi']});
    expect((i.ratePaise, i.sessionMinutes, i.isAvailable), (15000, 30, true));
    expect(Interpreter.fromJson({'id': 'i2', 'name': 'Asha'}).ratePaise, 0);
  });

  test('request states: awaiting_payment carries the Razorpay order', () {
    final r = CallRequestState.fromJson({
      'requestId': 'r1',
      'status': 'awaiting_payment',
      'order': {'order_id': 'order_1', 'amount': 15000, 'currency': 'INR', 'keyId': 'rzp_test_x'},
    });
    expect(r.status, RequestStatus.awaitingPayment);
    expect((r.order?.orderId, r.order?.amountPaise), ('order_1', 15000));
    expect(CallRequestState.fromJson({'requestId': 'r', 'status': 'waiting', 'position': 3}).queuePosition, 3);
  });

  test('profile and queue shapes', () {
    final me = InterpreterMe.fromJson({'approved': false, 'applied': true, 'ratePaise': 7500, 'languages': ['kn'], 'earningsPaise': 12000});
    expect((me.approved, me.applied, me.ratePaise, me.earningsPaise), (false, true, 7500, 12000));
    expect(InterpreterMe.fromJson({'approved': false}).applied, isFalse);
    final q = IncomingRequest.fromJson({'requestId': 'r', 'mode': 'video', 'language': 'hi', 'amountPaise': 15000, 'earnPaise': 12000, 'directed': true});
    expect((q.amountPaise, q.earnPaise, q.directed), (15000, 12000, true));
  });
}

void adminModelTest() {
  test('admin list item parses the backend shape', () {
    final a = AdminInterpreter.fromJson({'uid': 'u1', 'name': 'Ravi', 'email': 'r@x.com', 'languages': ['en'], 'ratePaise': 5000, 'approved': false});
    expect((a.uid, a.email, a.ratePaise, a.approved), ('u1', 'r@x.com', 5000, false));
  });
}
