import 'package:dukavo_mobile/core/api/api_exception.dart';
import 'package:dukavo_mobile/features/platform/application/platform_controller.dart';
import 'package:dukavo_mobile/features/platform/domain/platform_domain.dart';
import 'package:dukavo_mobile/features/platform/presentation/platform_dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

class _FailingPlatformRepository implements PlatformRepository {
  @override
  Future<PlatformDashboard> dashboard({String range = '30d'}) async {
    throw ApiException('Platform overview is unavailable.', statusCode: 500);
  }
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('a failed platform dashboard shows the error and a retry action',
      (tester) async {
    await pumpTestApp(
      tester,
      const PlatformDashboardScreen(),
      overrides: <Override>[
        platformRepositoryProvider
            .overrideWithValue(_FailingPlatformRepository()),
      ],
    );

    expect(find.text('Platform overview is unavailable.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
