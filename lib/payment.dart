import 'dart:async';
import 'dart:ui';
import 'package:webview_flutter/webview_flutter.dart';
import 'browse-store.dart';
import 'package:flutter/material.dart';
import 'server.dart';
import 'widgets.dart';
import 'dart:io';
import 'home.dart';

class PaymentView extends StatefulWidget {
  final String url;
  final Map<String, String> data;
  PaymentView({@required this.url, @required this.data});
  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final Completer<WebViewController> _controller =
      new Completer<WebViewController>();
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.black)),
          title: Text("Pay Securely", style: TextStyle(color: Colors.black)),
        ),
        body: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController wc) {
            _controller.complete(wc);
          },
          navigationDelegate: (NavigationRequest rq) {
            if (rq.url.contains("payment-successful")) {
              if (widget.data == null) {
                showDialog(
                    context: context,
                    builder: (context) => MessageDialog(
                        message: "Payment completed successfully"));
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false);
                return NavigationDecision.prevent;
              }
              placeOrder();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ));
  }

  Future placeOrder() async {
    widget.data['payment'] = "Completed";
    var response =
        await postMap('/customer/place-order/v3', widget.data, context);
    if (response.statusCode == 200) {
      await showDialog(
          context: context,
          builder: (context) => MessageDialog(message: response.body));
      cart.cartItems.clear();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
    }
  }
}
