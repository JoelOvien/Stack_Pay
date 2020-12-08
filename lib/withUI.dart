import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:stack_pay/constants.dart';

import 'main.dart';

class WithUI extends StatefulWidget {
  @override
  _WithUIState createState() => _WithUIState();
}

class _WithUIState extends State<WithUI> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
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
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.grey,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // new Row(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: <Widget>[
                //     new Expanded(
                //       child: const Text('Initalize transaction from:'),
                //     ),
                //     new Expanded(
                //       child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                //         new RadioListTile<int>(
                //           value: 0,
                //           groupValue: _radioValue,
                //           onChanged: _handleRadioValueChanged,
                //           title: const Text('Local'),
                //         ),
                //         new RadioListTile<int>(
                //           value: 1,
                //           groupValue: _radioValue,
                //           onChanged: _handleRadioValueChanged,
                //           title: const Text('Server'),
                //         ),
                //       ]),
                //     )
                //   ],
                // ),
                // _border,
                Text(
                  "Payment method",
                  style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total(USD-\$)",
                      style:
                          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "NGN3,900.00",
                      style:
                          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // _verticalSizeBox,
                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Card number',
                        ),
                        onSaved: (String value) => _cardNumber = value,
                      ),
                      _verticalSizeBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'CVV',
                              ),
                              onSaved: (String value) => _cvv = value,
                            ),
                          ),
                          _horizontalSizeBox,
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Expiry Month',
                              ),
                              onSaved: (String value) => _expiryMonth = int.tryParse(value),
                            ),
                          ),
                          _horizontalSizeBox,
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Expiry Year',
                              ),
                              onSaved: (String value) => _expiryYear = int.tryParse(value),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Theme(
                  data: Theme.of(context).copyWith(
                    accentColor: green,
                    primaryColorLight: Colors.white,
                    primaryColorDark: navyBlue,
                    textTheme: Theme.of(context).textTheme.copyWith(
                          bodyText2: TextStyle(
                            color: lightBlue,
                          ),
                        ),
                  ),
                  child: Builder(
                    builder: (context) {
                      return
                          // _inProgress
                          //     ? Container(
                          //         alignment: Alignment.center,
                          //         height: 50.0,
                          //         child: Platform.isIOS
                          //             ? CupertinoActivityIndicator()
                          //             : CircularProgressIndicator(),
                          //       )
                          //     :
                          Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _verticalSizeBox,
                          _getPlatformButton(
                              _inProgress
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'Make Payment'.toUpperCase(),
                                      style: const TextStyle(fontSize: 17.0),
                                    ),
                              () => _startAfreshCharge()),
                          _verticalSizeBox,
                          SizedBox(
                            height: 40.0,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _verticalSizeBox,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _handleRadioValueChanged(int value) => setState(() => _radioValue = value);

  _startAfreshCharge() async {
    _formKey.currentState.save();

    Charge charge = Charge();
    charge.card = _getCardFromUI();

    setState(() => _inProgress = true);

    // if (_isLocal) {
    //   // Set transaction params directly in app (note that these params
    //   // are only used if an access_code is not set. In debug mode,
    //   // setting them after setting an access code would throw an exception

    //   charge
    //     ..amount = 10000 // In base currency
    //     ..email = 'customer@email.com'
    //     ..reference = _getReference()
    //     ..putCustomField('Charged From', 'Flutter SDK');
    //   _chargeCard(charge);
    // } else {
    // Perform transaction/initialize on Paystack server to get an access code
    // documentation: https://developers.paystack.co/reference#initialize-a-transaction
    charge.accessCode = await _fetchAccessCodeFrmServer(_getReference());
    _chargeCard(charge);
    // }
  }

  _chargeCard(Charge charge) async {
    final response = await PaystackPlugin.chargeCard(context, charge: charge);

    final reference = response.reference;

    // Checking if the transaction is successful
    if (response.status) {
      _verifyOnServer(reference);
      return;
    }

    // The transaction failed. Checking if we should verify the transaction
    if (response.verify) {
      _verifyOnServer(reference);
    } else {
      setState(() => _inProgress = false);
      _updateStatus(reference, response.message);
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

  Widget _getPlatformButton(dynamic string, Function() function) {
    // is still in progress
    Widget widget;
    if (Platform.isIOS) {
      widget = Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.maxFinite,
          child: new CupertinoButton(
              onPressed: function,
              // padding: const EdgeInsets.symmetric(horizontal: 15.0),
              padding: EdgeInsets.symmetric(vertical: 15),
              color: CupertinoColors.activeBlue,
              child: string),
        ),
      );
    } else {
      widget = Container(
        // width: double.infinity,
        // height: 50,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.maxFinite,
          child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: function,
              color: Colors.blueAccent,
              textColor: Colors.white,
              // padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
              child: string),
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

  void _verifyOnServer(String reference) async {
    _updateStatus(reference, 'Verifying...');
    String url = '$backendUrl/verify/$reference';
    try {
      http.Response response = await http.get(url);
      var body = response.body;
      _updateStatus(reference, body);
    } catch (e) {
      _updateStatus(
          reference,
          'There was a problem verifying %s on the backend: '
          '$reference $e');
    }
    setState(() => _inProgress = false);
  }

  _updateStatus(String reference, String message) {
    _showMessage('Reference: $reference \n\ Response: $message');
  }

  _showMessage(
    String message,
  ) {
    return ToastUtils.showToast(message);
    // _scaffoldKey.currentState.showSnackBar(new SnackBar(
    //   content: new Text(message),
    //   duration: duration,
    //   action: new SnackBarAction([Duration duration = const Duration(seconds: 4)]
    //       label: 'CLOSE', onPressed: () => _scaffoldKey.currentState.removeCurrentSnackBar()), , const Duration(seconds: 7)
    // ));
  }

  // bool get _isLocal => _radioValue == 0;
}
