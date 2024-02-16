import 'package:flutter/material.dart';
import '/localization/app_localization.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Not Found'.tr()),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.info_outline,
                size: 80.0,
                color: Colors.black38,
              ),
              SizedBox(height: 24.0),
              Text(
                'Sorry, the page you have requested is not available.'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Go back".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
