import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/features/interpreter/domain/interpreter_models.dart';

void main() {
  test('queue item and profile parse the backend shapes', () {
    final r = IncomingRequest.fromJson({'requestId': 'r1', 'name': 'Asha', 'mode': 'audio', 'language': 'hi', 'note': '', 'waitingSeconds': 12});
    expect((r.mode, r.note, r.waitingSeconds), (CallMode.audio, null, 12));
    expect(InterpreterMe.fromJson({'approved': false}).approved, isFalse);
    final me = InterpreterMe.fromJson({'approved': true, 'status': 'available', 'name': 'Ravi'});
    expect((me.approved, me.status), (true, InterpreterStatus.available));
  });
}
