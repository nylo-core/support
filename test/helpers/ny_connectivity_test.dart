import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  NyTest.init();

  nyGroup('NyConnectivityState', () {
    nyTest('should have all expected values', () async {
      expect(NyConnectivityState.values, hasLength(7));
      expect(NyConnectivityState.values, contains(NyConnectivityState.wifi));
      expect(NyConnectivityState.values, contains(NyConnectivityState.mobile));
      expect(
        NyConnectivityState.values,
        contains(NyConnectivityState.ethernet),
      );
      expect(NyConnectivityState.values, contains(NyConnectivityState.vpn));
      expect(
        NyConnectivityState.values,
        contains(NyConnectivityState.bluetooth),
      );
      expect(NyConnectivityState.values, contains(NyConnectivityState.other));
      expect(NyConnectivityState.values, contains(NyConnectivityState.none));
    });
  });

  nyGroup('ConnectivityResultExtension.toNyState', () {
    nyTest('should convert wifi', () async {
      expect(ConnectivityResult.wifi.toNyState(), NyConnectivityState.wifi);
    });

    nyTest('should convert mobile', () async {
      expect(ConnectivityResult.mobile.toNyState(), NyConnectivityState.mobile);
    });

    nyTest('should convert ethernet', () async {
      expect(
        ConnectivityResult.ethernet.toNyState(),
        NyConnectivityState.ethernet,
      );
    });

    nyTest('should convert vpn', () async {
      expect(ConnectivityResult.vpn.toNyState(), NyConnectivityState.vpn);
    });

    nyTest('should convert bluetooth', () async {
      expect(
        ConnectivityResult.bluetooth.toNyState(),
        NyConnectivityState.bluetooth,
      );
    });

    nyTest('should convert other', () async {
      expect(ConnectivityResult.other.toNyState(), NyConnectivityState.other);
    });

    nyTest('should convert none', () async {
      expect(ConnectivityResult.none.toNyState(), NyConnectivityState.none);
    });
  });
}
