import 'package:customer_app/cubit_folder/otp_verification_cubit.dart';
import 'package:customer_app/cubit_folder/otp_verification_state.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/verify_otp_model.dart';
import 'package:customer_app/pages/register_screen.dart';
import 'package:customer_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OTP verification does not require an auth token', () async {
    final cubit = OtpVerificationCubit(_FakeAuthApi());

    await cubit.verify(
      model: VerifyOtpModel(email: 'user@example.com', code: '12345678'),
    );

    expect(cubit.state, isA<OtpVerificationSuccess>());
    await cubit.close();
  });

  testWidgets('Register screen rejects invalid email format', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: RegisterScreen(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'الاسم الكامل'),
      'مستخدم تجريبي',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'البريد الإلكتروني'),
      'invalid-email',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'رقم الهاتف'),
      '0999999999',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'كلمة المرور'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'تأكيد كلمة المرور'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'رقم الهوية'),
      '123456789',
    );

    final submitButton = find.widgetWithText(ElevatedButton, 'إنشاء الحساب');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('الرجاء إدخال بريد إلكتروني صحيح'), findsOneWidget);
  });

  testWidgets('App logo renders the configured asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AppLogo())),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, kAppLogoAsset);
  });
}

class _FakeAuthApi extends AuthApi {
  @override
  Future<Map<String, dynamic>> verifyOtp({
    required VerifyOtpModel model,
    String? token,
  }) async {
    expect(token, isNull);
    return {'message': 'تم تأكيد الحساب بنجاح'};
  }
}
