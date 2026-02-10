import 'package:flutter/material.dart';
import '/localization/ny_localization.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('nylo.page_not_found.title'.tr())),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.info_outline, size: 80.0, color: Colors.black38),
              const SizedBox(height: 24.0),
              Text(
                'nylo.page_not_found.message'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("nylo.page_not_found.go_back".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
