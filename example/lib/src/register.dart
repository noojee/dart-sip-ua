import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sip_ua_helper.dart';

class RegisterWidget extends StatefulWidget {
  final SIPUAHelper _helper;
  RegisterWidget(this._helper, {Key key}) : super(key: key);
  @override
  _MyRegisterWidget createState() => _MyRegisterWidget();
}

class _MyRegisterWidget extends State<RegisterWidget> {
  String _password;
  var _wsUri = 'wss://tryit.jssip.net:10443';
  var _sipUri = 'hello_flutter@tryit.jssip.net';
  var _displayName = 'Flutter SIP UA';
  SharedPreferences prefs;
  String _registerState;

  SIPUAHelper get helper => widget._helper;

  @override
  initState() {
    super.initState();
    _registerState = helper.registerState;
    helper.on('registerState', _handleRegisterState);
    helper.on('socketState', _handleSocketState);
  }

  @override
  deactivate() {
    super.deactivate();
    helper.remove('registerState', _handleRegisterState);
    helper.remove('socketState', _handleSocketState);
  }

  void _handleRegisterState(String state, Map<String, dynamic> data) {
    this.setState(() {
      _registerState = state;
    });
  }

  void _handleSocketState(String state, Map<String, dynamic> data) {
    this.setState(() {
      _registerState = state;
    });
  }

  void _alert(BuildContext context, String alertFieldName) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$alertFieldName is empty'),
          content: Text('Please enter $alertFieldName!'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSave(BuildContext context) {
    if (_wsUri == null) {
      _alert(context, "WebSocket URL");
    } else if (_sipUri == null) {
      _alert(context, "SIP URI");
    }

    Map<String, dynamic> wsExtraHeaders = Map<String, dynamic>();
    wsExtraHeaders['Origin'] = ' https://tryit.jssip.net';
    wsExtraHeaders['Host'] = 'tryit.jssip.net:10443';

    helper.start(_wsUri, _sipUri, _password, _displayName, wsExtraHeaders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("SIP Account"),
        ),
        body: Align(
            alignment: Alignment(0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 18.0),
                        child: Center(
                            child: Text(
                          'Register Status: $_registerState',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 0),
                        child: Align(
                          child: Text('WebSocket:'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            hintText: _wsUri,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _wsUri = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          child: Text('SIP URI:'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            hintText: _sipUri,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _sipUri = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          child: Text('Password:'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            hintText: '[Empty]',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          child: Text('Display Name:'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            hintText: _displayName,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _displayName = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 0.0),
                      child: Container(
                        height: 48.0,
                        width: 160.0,
                        child: MaterialButton(
                          child: Text(
                            'Register',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => _handleSave(context),
                        ),
                      ))
                ])));
  }
}
