import 'package:get/get.dart';

import '../model/model.dart';

class MouseController extends GetxController implements IMouseService {
  // Reactive variable for the click status
  final RxString _clickStatus = 'Click a button'.obs;

  @override
  String get clickStatus => _clickStatus.value;

  @override
  void leftClick() {
    _clickStatus.value = 'Left Button Clicked';
  }

  @override
  void rightClick() {
    _clickStatus.value = 'Right Button Clicked';
  }
}
