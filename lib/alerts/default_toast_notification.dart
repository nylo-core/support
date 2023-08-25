import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_meta.dart';
import 'package:nylo_support/helpers/helper.dart';

class DefaultToastNotification extends StatelessWidget {
  const DefaultToastNotification(ToastMeta toastMeta, {Key? key, this.dismiss})
      : _toastMeta = toastMeta,
        super(key: key);

  final ToastMeta _toastMeta;
  final Function? dismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0),
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        height: 100,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: _toastMeta.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Pulse(
              child: Container(
                child: Center(
                  child: IconButton(
                    onPressed: () {},
                    icon: _toastMeta.icon ?? SizedBox.shrink(),
                    padding: EdgeInsets.only(right: 16),
                  ),
                ),
              ),
              infinite: true,
              duration: Duration(milliseconds: 1500),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    trans(_toastMeta.title),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  Text(
                    trans(_toastMeta.description),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: IconButton(
            onPressed: () {
              if (dismiss == null) return;
              dismiss!();
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
            )),
      )
    ]);
  }
}
