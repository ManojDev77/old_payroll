import 'package:get/get.dart';

import '../controller/var_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VarController>(() => VarController());
  }
}
