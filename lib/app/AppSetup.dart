import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mobileraker/WebSocket.dart';
import 'package:mobileraker/dto/machine/PrinterSetting.dart';
import 'package:mobileraker/dto/machine/WebcamSetting.dart';
import 'package:mobileraker/service/KlippyService.dart';
import 'package:mobileraker/service/PrinterService.dart';
import 'package:mobileraker/service/PrinterSettingsService.dart';
import 'package:mobileraker/service/SelectedMachineService.dart';
import 'package:mobileraker/ui/dialog/editForm/editForm_view.dart';
import 'package:mobileraker/ui/overview/overview_view.dart';
import 'package:mobileraker/ui/printers/add/printers_add_view.dart';
import 'package:mobileraker/ui/printers/edit/printers_edit_view.dart';
import 'package:mobileraker/ui/printers/printers_view.dart';
import 'package:mobileraker/ui/setting/setting_view.dart';
import 'package:mobileraker/ui/test_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import 'AppSetup.locator.dart';

@StackedApp(routes: [
  MaterialRoute(page: OverView, initial: true),
  CupertinoRoute(page: SettingView),
  CupertinoRoute(page: Printers),
  MaterialRoute(page: PrintersAdd),
  MaterialRoute(page: PrintersEdit),
], dependencies: [
  LazySingleton(classType: NavigationService),
  LazySingleton(classType: SnackbarService),
  LazySingleton(classType: DialogService),
], logger: StackedLogger())
class AppSetup {}

enum DialogType { editForm, connectionError }

registerPrinters() async {
  // replace with loop for all printers added to local storage TODO
  final locator = StackedLocator.instance;
  var selectedMachineService = SelectedMachineService();
  var printerSettingsService = PrinterSettingsService(selectedMachineService);
  locator.registerSingleton<SelectedMachineService>(selectedMachineService);
  locator.registerSingleton<PrinterSettingsService>(printerSettingsService);
}

openBoxes() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PrinterSettingAdapter());
  Hive.registerAdapter(WebcamSettingAdapter());
  // Hive.deleteBoxFromDisk('printers');
  await Future.wait([
    Hive.openBox<PrinterSetting>('printers'),
    Hive.openBox<String>('uuidbox'),
  ]);
}

setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    DialogType.editForm: (context, sheetRequest, completer) =>
        FormDialogView(request: sheetRequest, completer: completer),
  };
  dialogService.registerCustomDialogBuilders(builders);
}

setupNotifications() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ]);

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}