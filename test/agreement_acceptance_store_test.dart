import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:milo_ai/app/core/agreement/agreement_acceptance_store.dart';

void main() {
  test('agreement gate is required until the current version is accepted',
      () async {
    SharedPreferences.setMockInitialValues({});
    const store = AgreementAcceptanceStore();

    expect(await store.shouldShowAgreementGate(), isTrue);

    await store.acceptCurrentAgreement();

    expect(await store.shouldShowAgreementGate(), isFalse);
  });

  test('agreement gate is required when the accepted version is stale',
      () async {
    SharedPreferences.setMockInitialValues({
      AgreementAcceptanceStore.acceptedKey: true,
      AgreementAcceptanceStore.versionKey: '2026-06-26',
    });
    const store = AgreementAcceptanceStore();

    expect(await store.shouldShowAgreementGate(), isTrue);
  });
}
