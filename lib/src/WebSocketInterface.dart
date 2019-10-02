import 'dart:io';

import 'Grammar.dart';
import 'Socket.dart';
import 'Timers.dart';
import 'logger.dart';

class WebSocketInterface implements Socket {
  String _url;
  String _sip_uri;
  String _via_transport;
  WebSocket _ws;
  var _closed = false;
  var _connected = false;
  var weight;
  var _wsExtraHeaders;

  final logger = Logger('WebSocketInterface');
  debug(msg) => logger.debug(msg);
  debugerror(error) => logger.error(error);
  @override
  dynamic onconnect;
  @override
  dynamic ondisconnect;
  @override
  dynamic ondata;

  WebSocketInterface(url, [wsExtraHeaders]) {
    debug('new() [url:' + url + ']');
    this._url = url;
    var parsed_url = Grammar.parse(url, 'absoluteURI');
    if (parsed_url == -1) {
      debugerror('invalid WebSocket URI: ${url}');
      throw new AssertionError('Invalid argument: ${url}');
    } else if (parsed_url.scheme != 'wss' && parsed_url.scheme != 'ws') {
      debugerror('invalid WebSocket URI scheme: ${parsed_url.scheme}');
      throw new AssertionError('Invalid argument: ${url}');
    } else {
      var port = parsed_url.port != null ? ':${parsed_url.port}' : '';
      this._sip_uri = 'sip:${parsed_url.host}${port};transport=ws';
      debug('SIP URI: ${this._sip_uri}');
      this._via_transport = parsed_url.scheme.toUpperCase();
    }
    this._wsExtraHeaders = wsExtraHeaders ?? {};
  }

  @override
  get via_transport => this._via_transport;

  set via_transport(value) {
    this._via_transport = value.toUpperCase();
  }

  @override
  get sip_uri => this._sip_uri;

  @override
  get url => this._url;

  @override
  connect() async {
    debug('connect()');
    if (this.isConnected()) {
      debug('WebSocket ${this._url} is already connected');
      return;
    } else if (this.isConnecting()) {
      debug('WebSocket ${this._url} is connecting');
      return;
    }
    if (this._ws != null) {
      this.disconnect();
    }
    debug('connecting to WebSocket ${this._url}');
    try {
      this._ws = await WebSocket.connect(this._url,
          headers: {'Sec-WebSocket-Protocol': 'sip', ...this._wsExtraHeaders});
      this._ws.listen((data) {
        this._onMessage(data);
      }, onDone: () {
        logger.debug(
            'Closed by server [${this._ws.closeCode}, ${this._ws.closeReason}]!');
        _connected = false;
        this._onClose(true, this._ws.closeCode, this._ws.closeReason);
      });
      _closed = false;
      _connected = true;
      this._onOpen();
    } catch (e) {
      _connected = false;
      this._onError(e.toString());
    }
  }

  @override
  disconnect() {
    debug('disconnect()');
    if (this._closed) return;
    // Don't wait for the WebSocket 'close' event, do it now.
    this._closed = true;
    this._connected = false;
    this._onClose(true, 0, "Client send disconnect");
    try {
      if (this._ws != null) {
        this._ws.close();
      }
    } catch (error) {
      debugerror('close() | error closing the WebSocket: ' + error);
    }
  }

  @override
  send(message) {
    debug('send()');
    if (this._closed) {
      throw 'transport closed';
    }
    try {
      // temporary diagnostic message add to the end of every SIP message sent
      var now = new DateTime.now();
      String tmp = message +
          "\nSIP message generated and sent at: ${now}\n"; // + ("A" * 4096);

      this._ws.add(tmp);
      setTimeout(() {
        // extra message to wake asterisk up
        this._ws.add("");
      }, 100);

      return true;
    } catch (error) {
      logger.failure('send() | error sending message: ' + error.toString());
      throw error;
    }
  }

  isConnected() {
    return _connected;
  }

  isConnecting() {
    return this._ws != null && this._ws.readyState == WebSocket.connecting;
  }

  /**
   * WebSocket Event Handlers
   */
  _onOpen() {
    debug('WebSocket ${this._url} connected');
    this.onconnect();
  }

  _onClose(wasClean, code, reason) {
    debug('WebSocket ${this._url} closed');
    if (wasClean == false) {
      debug('WebSocket abrupt disconnection');
    }
    var data = {
      'socket': this,
      'error': !wasClean,
      'code': code,
      'reason': reason
    };
    this.ondisconnect(data);
  }

  _onMessage(data) {
    debug('Received WebSocket message');
    if (data != null) {
      if (data.toString().trim().length > 0) {
        this.ondata(data);
      } else {
        debug("Received and ignored empty packet");
      }
    }
  }

  _onError(e) {
    debugerror('WebSocket ${this._url} error: ${e}');
  }
}
