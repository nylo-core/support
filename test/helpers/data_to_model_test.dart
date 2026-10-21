import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/networking/ny_networking.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/testing/ny_testing.dart';

class Profile {
  Profile.fromJson(dynamic json) : name = json['name'] as String;

  final String name;
}

sealed class Notice {}

final class Alert extends Notice {
  Alert.fromJson(dynamic json) : text = json['text'] as String;

  final String text;
}

final class Promo extends Notice {
  Promo.fromJson(dynamic json) : code = json['code'] as String;

  final String code;
}

final Map<Type, dynamic> _decoders = {
  Profile: (data) => Profile.fromJson(data),
  Notice: OneOf<Notice>.byKey('type', {
    'alert': Alert.fromJson,
    'promo': Promo.fromJson,
  }),
};

void main() {
  NyTest.init();

  nyGroup('dataToModel', () {
    nyTest('decodes with a closure decoder', () async {
      final Profile profile = dataToModel<Profile>(
        data: {'name': 'Ada'},
        modelDecoders: _decoders,
      );

      expect(profile.name, 'Ada');
    });

    nyTest('decodes with a OneOf', () async {
      final Notice notice = dataToModel<Notice>(
        data: {'type': 'promo', 'code': 'SAVE10'},
        modelDecoders: _decoders,
      );

      expect(notice, isA<Promo>());
    });

    nyTest('decodes a list through a OneOf without a list entry', () async {
      final List<Notice> notices = dataToModel<List<Notice>>(
        data: [
          {'type': 'alert', 'text': 'Hi'},
          {'type': 'promo', 'code': 'SAVE10'},
        ],
        modelDecoders: _decoders,
      );

      expect(notices.map((notice) => notice.runtimeType), [Alert, Promo]);
    });

    nyTest('uses the decoders registered with Nylo', () async {
      final Nylo nylo = Nylo();
      nylo.addModelDecoders(_decoders);
      Backpack.instance.save('nylo', nylo);

      final Notice notice = dataToModel<Notice>(
        data: {'type': 'alert', 'text': 'Saved'},
      );

      expect(notice, isA<Alert>());
    });

    nyTest('reads a OneOf model back from Backpack', () async {
      final Nylo nylo = Nylo();
      nylo.addModelDecoders(_decoders);
      Backpack.instance.save('nylo', nylo);
      Backpack.instance.save('last_notice', {'type': 'promo', 'code': 'X1'});

      final Notice? notice = Backpack.instance.read<Notice>('last_notice');

      expect(notice, isA<Promo>());
    });
  });
}
