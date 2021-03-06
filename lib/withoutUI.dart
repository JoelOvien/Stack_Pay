import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:stack_pay/constants.dart';

import 'main.dart';

class WithoutUI extends StatefulWidget {
  @override
  _WithoutUIState createState() => _WithoutUIState();
}

class _WithoutUIState extends State<WithoutUI> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  var _border = new Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.red,
  );
  int _radioValue = 0;
  CheckoutMethod _method;
  bool _inProgress = false;
  String _cardNumber;
  String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;
  @override
  void initState() {
    PaystackPlugin.initialize(publicKey: paystackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: const Text("Without UI")),
      body: new Container(
        padding: const EdgeInsets.all(20.0),
        child: new Form(
          key: _formKey,
          child: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Expanded(
                      child: const Text('Initalize transaction from:'),
                    ),
                    new Expanded(
                      child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        new RadioListTile<int>(
                          value: 0,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChanged,
                          title: const Text('Local'),
                        ),
                        new RadioListTile<int>(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChanged,
                          title: const Text('Server'),
                        ),
                      ]),
                    )
                  ],
                ),
                _border,
                _verticalSizeBox,
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Flexible(
                      flex: 3,
                      child: new DropdownButtonHideUnderline(
                        child: new InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            hintText: 'Checkout method',
                          ),
                          isEmpty: _method == null,
                          child: new DropdownButton<CheckoutMethod>(
                            value: _method,
                            isDense: true,
                            onChanged: (CheckoutMethod value) {
                              setState(() {
                                _method = value;
                              });
                            },
                            items: banks.map((String value) {
                              return new DropdownMenuItem<CheckoutMethod>(
                                value: _parseStringToMethod(value),
                                child: new Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    _horizontalSizeBox,
                    new Flexible(
                      flex: 2,
                      child: new Container(
                        width: double.infinity,
                        child: _getPlatformButton(
                          'Checkout',
                          () => _handleCheckout(context),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRadioValueChanged(int value) => setState(() => _radioValue = value);

  _handleCheckout(BuildContext context) async {
    if (_method == null) {
      _showMessage('Select checkout method first');
      return;
    }

    if (_method != CheckoutMethod.card && _isLocal) {
      _showMessage('Select server initialization method at the top');
      return;
    }
    setState(() => _inProgress = true);
    _formKey.currentState.save();
    Charge charge = Charge()
      ..amount = 20000 * 100 // In base currency
      ..email = 'customer@gmail.com'
      ..card = _getCardFromUI();

    if (!_isLocal) {
      var accessCode = await _fetchAccessCodeFrmServer(_getReference());
      charge.accessCode = accessCode;
    } else {
      charge.reference = _getReference();
    }

    try {
      CheckoutResponse response = await PaystackPlugin.checkout(
        context,
        method: _method,
        charge: charge,
        fullscreen: false,
        logo: MyLogo(),
      );
      print('Response = $response');
      setState(() => _inProgress = false);
      _updateStatus(response.reference, '$response');
    } catch (e) {
      setState(() => _inProgress = false);
      _showMessage("Check console for error");
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );

    // Using Cascade notation (similar to Java's builder pattern)
//    return PaymentCard(
//        number: cardNumber,
//        cvc: cvv,
//        expiryMonth: expiryMonth,
//        expiryYear: expiryYear)
//      ..name = 'Segun Chukwuma Adamu'
//      ..country = 'Nigeria'
//      ..addressLine1 = 'Ikeja, Lagos'
//      ..addressPostalCode = '100001';

    // Using optional parameters
//    return PaymentCard(
//        number: cardNumber,
//        cvc: cvv,
//        expiryMonth: expiryMonth,
//        expiryYear: expiryYear,
//        name: 'Ismail Adebola Emeka',
//        addressCountry: 'Nigeria',
//        addressLine1: '90, Nnebisi Road, Asaba, Deleta State');
  }

  Widget _getPlatformButton(String string, Function() function) {
    // is still in progress
    Widget widget;
    if (Platform.isIOS) {
      widget = new CupertinoButton(
        onPressed: function,
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        color: CupertinoColors.activeBlue,
        child: new Text(
          string,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      widget = new RaisedButton(
        onPressed: function,
        color: Colors.blueAccent,
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: new Text(
          string.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
    return widget;
  }

  Future<String> _fetchAccessCodeFrmServer(String reference) async {
    String url = '$backendUrl/new-access-code';
    String accessCode;
    try {
      print("Access code url = $url");
      http.Response response = await http.get(url);
      accessCode = response.body;
      print('Response for access code = $accessCode');
    } catch (e) {
      setState(() => _inProgress = false);
      _updateStatus(
          reference,
          'There was a problem getting a new access code form'
          ' the backend: $e');
    }

    return accessCode;
  }

  _updateStatus(String reference, String message) {
    _showMessage('Reference: $reference \n\ Response: $message', const Duration(seconds: 7));
  }

  _showMessage(String message, [Duration duration = const Duration(seconds: 4)]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
      duration: duration,
      action: new SnackBarAction(
          label: 'CLOSE', onPressed: () => _scaffoldKey.currentState.removeCurrentSnackBar()),
    ));
  }

  bool get _isLocal => _radioValue == 0;
}

var banks = ['Selectable', 'Bank', 'Card'];

CheckoutMethod _parseStringToMethod(String string) {
  CheckoutMethod method = CheckoutMethod.selectable;
  switch (string) {
    case 'Bank':
      method = CheckoutMethod.bank;
      break;
    case 'Card':
      method = CheckoutMethod.card;
      break;
  }
  return method;
}
