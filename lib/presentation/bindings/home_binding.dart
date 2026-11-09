import 'package:get/get.dart';

import '../../data/repositories/portfolio_repository_impl.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PortfolioRepository>(() => PortfolioRepositoryImpl());
    Get.lazyPut<HomeController>(HomeController.new);
  }
}
