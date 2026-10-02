import 'package:get/get.dart';
import 'app_routes.dart';
import '../../../features/welcome/welcome_view.dart';
import '../../../features/welcome/welcome_controller.dart';
import '../../../features/auth/login/login_view.dart';
import '../../../features/auth/login/login_controller.dart';
import '../../../features/auth/signup/signup_view.dart';
import '../../../features/auth/signup/signup_controller.dart';
import '../../../features/dashboard/dashboard_view.dart';
import '../../../features/dashboard/dashboard_controller.dart';
import '../../../features/jobcard/jobcard_create_view.dart';
import '../../../features/jobcard/jobcard_create_controller.dart';
import '../../../features/reminders/service_reminders_view.dart';
import '../../../features/reminders/service_reminders_controller.dart';
import '../../../features/revenue/revenue_management_view.dart';
import '../../../features/revenue/revenue_management_controller.dart';
import '../../../features/bookings/bookings_view.dart';
import '../../../features/bookings/bookings_controller.dart';
import '../../../features/reports/reports_view.dart';
import '../../../features/reports/reports_controller.dart';
import '../../../features/inventory/inventory_view.dart';
import '../../../features/inventory/inventory_add_view.dart';
import '../../../features/inventory/inventory_controller.dart';
import '../../../features/payment_qr/payment_qr_view.dart';
import '../../../features/payment_qr/payment_qr_controller.dart';
import '../../../features/profile/profile_view.dart';
import '../../../features/profile/profile_edit_view.dart';
import '../../../features/profile/profile_controller.dart';
import '../../../features/staff/staff_view.dart';
import '../../../features/staff/staff_add_view.dart';
import '../../../features/staff/staff_controller.dart';
import '../../../features/jobcard/jobcard_list_view.dart';
import '../../../features/jobcard/jobcard_list_controller.dart';
import '../../../features/jobcard/jobcard_details_view.dart';
import '../../../features/jobcard/jobcard_details_controller.dart';


class AppPages {
  static const String initial = AppRoutes.welcome;

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WelcomeController>(() => WelcomeController());
      }),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SignupController>(() => SignupController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
      transition: Transition.zoom,
    ),
    GetPage(
      name: AppRoutes.createJobCard,
      page: () => const JobCardCreateView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<JobCardCreateController>(() => JobCardCreateController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.reminders,
      page: () => const ServiceRemindersView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ServiceRemindersController>(() => ServiceRemindersController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.revenue,
      page: () => const RevenueManagementView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RevenueManagementController>(() => RevenueManagementController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.bookings,
      page: () => const BookingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BookingsController>(() => BookingsController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportsController>(() => ReportsController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InventoryController>(() => InventoryController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.inventoryAdd,
      page: () => const InventoryAddView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InventoryController>(() => InventoryController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.paymentQr,
      page: () => const PaymentQrView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentQrController>(() => PaymentQrController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const GarageProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.profileEdit,
      page: () => const GarageProfileEditView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.staff,
      page: () => const StaffView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StaffController>(() => StaffController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.staffAdd,
      page: () => const StaffAddView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StaffController>(() => StaffController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.jobCardList,
      page: () => const JobCardListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<JobCardListController>(() => JobCardListController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.jobCardDetails,
      page: () => const JobCardDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<JobCardDetailsController>(() => JobCardDetailsController());
      }),
      transition: Transition.fadeIn,
    ),
  ];
}
