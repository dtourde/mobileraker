import 'package:hive/hive.dart';
import 'package:mobileraker/datasource/websocket_wrapper.dart';
import 'package:mobileraker/dto/machine/temperature_preset.dart';
import 'package:mobileraker/dto/machine/webcam_setting.dart';
import 'package:mobileraker/service/file_service.dart';
import 'package:mobileraker/service/klippy_service.dart';
import 'package:mobileraker/service/printer_service.dart';
import 'package:uuid/uuid.dart';

part 'printer_setting.g.dart';

@HiveType(typeId: 1)
class PrinterSetting extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String wsUrl;
  @HiveField(2)
  String uuid = Uuid().v4();
  @HiveField(3, defaultValue: [])
  List<WebcamSetting> cams;
  @HiveField(4)
  String? apiKey;
  @HiveField(5, defaultValue: [])
  List<TemperaturePreset> temperaturePresets;
  @HiveField(6,
      defaultValue:
          '') //TODO: Remove defaultValue section once more ppl. used this version
  String httpUrl;

  WebSocketWrapper? _webSocket;

  WebSocketWrapper get websocket {
    if (_webSocket == null)
      _webSocket =
          WebSocketWrapper(wsUrl, Duration(seconds: 5), apiKey: apiKey);

    return _webSocket!;
  }

  PrinterService? _printerService;

  PrinterService get printerService {
    if (_printerService == null) _printerService = PrinterService(websocket);
    return _printerService!;
  }

  KlippyService? _klippyService;

  KlippyService get klippyService {
    if (_klippyService == null) _klippyService = KlippyService(websocket);
    return _klippyService!;
  }

  FileService? _fileService;

  FileService get fileService {
    if (_fileService == null) _fileService = FileService(websocket);
    return _fileService!;
  }

  PrinterSetting(
      {required this.name,
      required this.wsUrl,
      required this.httpUrl,
      this.apiKey,
      this.temperaturePresets = const [],
      this.cams = const []}) {
    //TODO: Remove this section once more ppl. used this version
    if (httpUrl.isEmpty) this.httpUrl = 'http://${Uri.parse(wsUrl).host}';
  }

  @override
  Future<void> save() async {
    await super.save();

    // ensure websocket gets updated with the changed URL+API KEY
    _webSocket?.update(this.wsUrl, this.apiKey);
  }

  @override
  Future<void> delete() async {
    await super.delete();
    _printerService?.printerStream.close();
    _klippyService?.klipperStream.close();
    _webSocket?.reset();
    _webSocket?.stateStream.close();
    return;
  }
}