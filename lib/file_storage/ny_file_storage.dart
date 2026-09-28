/// File storage for Nylo: named disks over the device's folders, the app
/// bundle, memory, or any driver you write, in the style of Laravel's
/// `Storage` facade.
///
/// ```dart
/// await disk('documents').put('reports/q3.pdf', pdfBytes);
/// final String avatar = await disk().putFile('avatars', photo);
/// Image(image: DiskImage(avatar));
/// ```
library ny_file_storage;

export 'package:cross_file/cross_file.dart' show XFile;

export 'src/disk.dart';
export 'src/disk_config.dart';
export 'src/disk_driver.dart';
export 'src/disk_exceptions.dart';
export 'src/disk_image.dart';
export 'src/drivers/asset_disk_driver.dart';
export 'src/drivers/local_disk_driver.dart';
export 'src/drivers/memory_disk_driver.dart';
export 'src/file_storage.dart';
