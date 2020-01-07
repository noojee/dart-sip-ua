import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'enum_helper.dart';
import 'stack_trace_nj.dart';

class Log extends Logger {
  static Log _self;
  static String _localPath;

  static Level _loggingLevel = Level.debug;

  Log();

  static set loggingLevel(Level loggingLevel) => _loggingLevel = loggingLevel;

  Log._internal(String currentWorkingDirectory)
      : super(printer: MyLogPrinter(currentWorkingDirectory));

  void debug(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    Log.d(message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    Log.i(message, error, stackTrace);
  }

  void warn(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    Log.w(message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    Log.e(message, error, stackTrace);
  }

  factory Log.d(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    _self.d(message, error, stackTrace);
    return _self;
  }

  factory Log.i(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    _self.i(message, error, stackTrace);
    return _self;
  }

  factory Log.w(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    _self.w(message, error, stackTrace);
    return _self;
  }

  factory Log.e(String message, [dynamic error, StackTrace stackTrace]) {
    autoInit();
    _self.e(message, error, stackTrace);
    return _self;
  }

  static void autoInit() {
    if (_self == null) {
      init(".");
    }
  }

  static void init(String currentWorkingDirectory) {
    _self = Log._internal(currentWorkingDirectory);

    StackTraceNJ frames = StackTraceNJ();

    for (Stackframe frame in frames.frames) {
      _localPath = frame.sourceFile.path
          .substring(frame.sourceFile.path.lastIndexOf("/"));
      break;
    }
  }
}

class MyLogPrinter extends LogPrinter {
  static final Map<Level, AnsiColor> levelColors = {
    Level.verbose: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: AnsiColor.none(),
    Level.info: AnsiColor.fg(12),
    Level.warning: AnsiColor.fg(208),
    Level.error: AnsiColor.fg(196),
  };

  bool colors = true;

  String currentWorkingDirectory;

  MyLogPrinter(this.currentWorkingDirectory);

  @override
  void log(LogEvent event) {
    if (EnumHelper.getIndexOf(Level.values, Log._loggingLevel) >
        EnumHelper.getIndexOf(Level.values, event.level)) {
      // don't log events where the log level is set higher
      return;
    }
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss.');
    var now = DateTime.now();
    var formattedDate = formatter.format(now) + now.millisecond.toString();

    var color = _getLevelColor(event.level);

    StackTraceNJ frames = StackTraceNJ();
    int i = 0;
    int depth = 0;
    for (Stackframe frame in frames.frames) {
      i++;
      var path2 = frame.sourceFile.path;
      if (!path2.contains(Log._localPath) && !path2.contains("logger.dart")) {
        depth = i - 1;
        break;
      }
    }

    print(color(
        "[$formattedDate] ${event.level} ${StackTraceNJ(skipFrames: depth).formatStackTrace(methodCount: 1)} ::: ${event.message}"));
    if (event.error != null) {
      print("${event.error}");
    }

    if (event.stackTrace != null) {
      if (event.stackTrace.runtimeType == StackTraceNJ) {
        var st = event.stackTrace as StackTraceNJ;
        print(color("${st}"));
      } else {
        print(color("${event.stackTrace}"));
      }
    }
  }

  AnsiColor _getLevelColor(Level level) {
    if (colors) {
      return levelColors[level];
    } else {
      return AnsiColor.none();
    }
  }
}

class AnsiColor {
  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = '\x1B[';

  /// Reset all colors and options for current SGRs to terminal defaults.
  static const ansiDefault = "${ansiEsc}0m";

  final int fg;
  final int bg;
  final bool color;

  AnsiColor.none()
      : fg = null,
        bg = null,
        color = false;

  AnsiColor.fg(this.fg)
      : bg = null,
        color = true;

  AnsiColor.bg(this.bg)
      : fg = null,
        color = true;

  String toString() {
    if (fg != null) {
      return "${ansiEsc}38;5;${fg}m";
    } else if (bg != null) {
      return "${ansiEsc}48;5;${bg}m";
    } else {
      return "";
    }
  }

  String call(String msg) {
    if (color) {
      return "${this}$msg$ansiDefault";
    } else {
      return msg;
    }
  }

  AnsiColor toFg() => AnsiColor.fg(bg);

  AnsiColor toBg() => AnsiColor.bg(fg);

  /// Defaults the terminal's foreground color without altering the background.
  String get resetForeground => color ? "${ansiEsc}39m" : "";

  /// Defaults the terminal's background color without altering the foreground.
  String get resetBackground => color ? "${ansiEsc}49m" : "";

  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();
}
