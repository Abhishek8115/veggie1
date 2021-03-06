import 'dart:async';
import 'dart:convert';
import 'home.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'server.dart';
import 'widgets.dart';
import 'cache.dart';
import 'browse-store.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'payment.dart';
import 'package:http/http.dart' as http;

class CartView extends StatefulWidget {
  final double percentCharge;
  final double constant;
  final double deliveryCharge;
  final List<Address> savedAddresses;
  final String mobile;
  CartView(
      {@required this.percentCharge,
      @required this.constant,
      @required this.deliveryCharge,
      @required this.savedAddresses,
      @required this.mobile});
  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  Address selectedAddress;
  TextEditingController _notes = TextEditingController(text: '');
  TextEditingController _mobile = TextEditingController(text: '');
  bool buildCart = true;
  String addressError, mobileErrorText;
  Position position;
  double serviceCharge = 0, discount = 0;
  bool initialized = false;
  GMapState state;
  Coupon coupon = Coupon(null, null, null, 0, double.infinity, 0);
  double total = 0;
  @override
  void initState() {
    super.initState();
  }

  Widget getToggleBtn(CartItem cartItem) {
    int quantity = cartItem.quantity;
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0, color: Colors.white)),
        margin: EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              child: Icon(Icons.remove_circle, size: 18),
              onTap: () {
                cart.decrement(cartItem.cartItemId);
                setState(() {
                  initialized = false;
                });
              },
            ),
            Text(" " + quantity.toString() + " ",
                style: TextStyle(color: Colors.black)),
            InkWell(
              child: Icon(Icons.add_circle, size: 18),
              onTap: () {
                cart.increment(cartItem.cartItemId);
                setState(() {
                  initialized = false;
                });
              },
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    total = serviceCharge = 0;
    selectedAddress =
        widget.savedAddresses.isEmpty ? null : widget.savedAddresses.first;
    _mobile.text = widget.mobile;
    List<Widget> bodyItems = [Divider(height: 10, color: Colors.transparent)];
    if (cart.cartItems.length == 0) {
      bodyItems.add(Container(
          height: MediaQuery.of(context).size.height - 100,
          child: Center(
              child: Text('No Items in Cart',
                  style: TextStyle(color: Colors.grey)))));
    }
    for (var cartItem in cart.cartItems) {
      total += double.parse(cartItem.price);
      bodyItems.add(Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.all(4)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                    child: CachedImage(
                      id: cartItem.itemId,
                      width: 70,
                      height: 60,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                Padding(padding: EdgeInsets.all(4)),
                getToggleBtn(cartItem),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
            Padding(padding: EdgeInsets.all(8)),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(child: Text(cartItem.header), width: 180),
                  Container(
                      child: Text(
                          cartItem.description
                              .replaceAll("@ " + Cache.currency + " 0.00", ""),
                          style: TextStyle(color: Colors.grey)),
                      width: 180)
                ]),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  color: Colors.orange[100],
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        Cache.currency + '  ' + cartItem.price,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                ),
                Padding(padding: EdgeInsets.all(4)),
              ],
            )
          ]));
    }
    discount = getDiscount(coupon);
    total += cart.cartItems.isEmpty ? 0 : widget.deliveryCharge;
    serviceCharge = total * widget.percentCharge / 100;
    serviceCharge += widget.constant;
    serviceCharge = serviceCharge.ceil().toDouble();
    total += cart.cartItems.isEmpty ? 0 : serviceCharge;
    total -= discount;
    if (cart.cartItems.length > 0)
      bodyItems.addAll([
        Divider(),
        getApplyCouponWidget(),
        Divider(),
        ListTile(
          contentPadding: EdgeInsets.only(left: 8),
          title: Text('Delivery Charge'),
          leading: Icon(
            Icons.delivery_dining,
            color: Colors.brown,
          ),
          trailing: Card(
            elevation: 0,
            color: Colors.orange[100],
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  Cache.currency +
                      '  ' +
                      widget.deliveryCharge.toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 8),
          title: Text('Service Charges + GST'),
          leading: Icon(
            Icons.miscellaneous_services,
            color: Colors.brown,
          ),
          trailing: Card(
            elevation: 0,
            color: Colors.orange[100],
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  Cache.currency + '  ' + serviceCharge.toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
          ),
        ),
        Divider(), Cache.orderType==0?
        ListTile(
          leading: Icon(Icons.location_pin, color: Colors.red, size: 30),
          title: Text('Delivering To', style: TextStyle(color: Colors.black)),
          subtitle: selectedAddress == null
              ? Text('No Address Chosen')
              : Text(
                  selectedAddress.flat +
                      ", " +
                      selectedAddress.colony +
                      ", " +
                      selectedAddress.landmark +
                      ", " +
                      selectedAddress.pincode,
                  style: TextStyle(color: Colors.grey)),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Colors.green, size: 18),
            onPressed: () {
              changeDeliveryAddress();
            },
          ),
        ) : Padding(padding: EdgeInsets.all(0)),
        Padding(
            child: TextField(
              onTap: () {
                setState(() {
                  mobileErrorText = null;
                });
              },
              controller: _mobile,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: InputDecoration(
                  errorText: mobileErrorText,
                  errorStyle: TextStyle(color: Colors.red),
                  labelText: 'Mobile Number',
                  counterText: ''),
              textInputAction: TextInputAction.done,
            ),
            padding: EdgeInsets.all(10)),
        Padding(
          child: TextField(
            controller: _notes,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Note for us (optional)'),
          ),
          padding: EdgeInsets.all(4),
        ),
      ]);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Your Cart',
            style: TextStyle(color: Cache.appBarActionsColor),
          ),
          centerTitle: false,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Cache.appBarActionsColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Column(children: [
          Expanded(
              child: ListView(
                  physics: BouncingScrollPhysics(), children: bodyItems)),
          SimpleBtn(
            backColor:
                cart.cartItems.length == 0 ? Colors.grey : Cache.appBarColor,
            onPressed: () async {
              if (cart.cartItems.length == 0) return;
              await placeOrder();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    child: Text(
                      'Place Order (' +
                          Cache.currency +
                          '  ' +
                          total.toStringAsFixed(2) +
                          ')',
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.all(10)),
              ],
            ),
          )
        ]));
  }

  void changeDeliveryAddress() {
    showDialog(
        context: context,
        builder: (context) {
          List<Widget> children = [];
          children = widget.savedAddresses
              .map((s) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                            selectedAddress = s;
                            setState(() {});
                          },
                          child: Container(
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width / 1.8,
                              child: Text(
                                  s.flat +
                                      ", " +
                                      s.colony +
                                      ", " +
                                      s.landmark +
                                      ", " +
                                      s.pincode,
                                  style: TextStyle(color: Colors.black)),
                              padding: EdgeInsets.all(8))),
                      IconButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) => Pending());
                            var response = await postMap(
                                '/customer/remove-address',
                                {
                                  'customerId': id,
                                  'password': password,
                                  'addressId': s.id
                                },
                                context);
                            if (response.statusCode == 200) {
                              widget.savedAddresses
                                  .removeWhere((e) => e.id == s.id);
                              selectedAddress = widget.savedAddresses.isEmpty
                                  ? null
                                  : widget.savedAddresses.first;
                            }
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                            setState(() {});
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                          },
                          icon: Icon(Icons.delete_forever,
                              color: Colors.red))
                    ],
                  ))
              .toList();
          children
              .add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
              child: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)),
                child:
                    Text('Add Address', style: TextStyle(color: Colors.white)),
              ),
              onTap: () async {
                if (Navigator.canPop(context)) Navigator.pop(context);
                Address add = await Navigator.push<Address>(context,
                    MaterialPageRoute(builder: (context) => AddNewAddress()));
                if (add != null)
                  setState(() {
                    widget.savedAddresses.insert(0, add);
                    selectedAddress = add;
                  });
              },
            )
          ]));
          return SimpleDialog(
              title:
                  Text('Select Address', style: TextStyle(color: Colors.black)),
              children: children.isEmpty? [Text('No Saved Address', style: TextStyle(color: Colors.grey))] : children);
        });
  }

  ListTile getApplyCouponWidget() {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text((coupon.code == null ? 'Apply Coupon' : coupon.code)),
      leading: Card(
        child: Padding(
            child: Text('%',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            padding: EdgeInsets.all(16)),
        color: Colors.green,
        shape: CircleBorder(),
      ),
      subtitle: Text((coupon.description == null ? '' : coupon.description)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          discount == 0
              ? Card()
              : Card(
                  elevation: 0,
                  color: Colors.green,
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '- ' +
                            Cache.currency +
                            '  ' +
                            discount.ceil().toStringAsFixed(2),
                        style: TextStyle(color: Colors.white),
                      )),
                ),
          IconButton(
            icon: Icon(Icons.view_list, color: Colors.green),
            onPressed: () async {
              applyCoupon();
            },
          ),
        ],
      ),
    );
  }

  Future applyCoupon() async {
    coupon = Coupon(null, null, null, 0, double.infinity, 0);
    showDialog(context: context, builder: (context) => Pending());
    var res = await postMap(
        '/customer/get-coupons',
        {
          'customerId': id,
          'password': password,
        },
        context);
    if (res.statusCode == 200) {
      List<Coupon> cps = (json.decode(res.body) as List)
          .map((c) => Coupon.fromJson(c))
          .toList();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (cps.length == 0) {
        await showDialog(
            context: context,
            builder: (context) =>
                MessageDialog(message: 'No Coupons are available'));
      } else {
        await showDialog(
            context: context,
            builder: (context) => SimpleDialog(
                children: cps
                    .map((c) => Card(
                        elevation: 1,
                        child: ListTile(
                          title: Text(c.code),
                          subtitle: Text(c.description),
                          trailing: FlatButton(
                            disabledColor: Colors.grey,
                            color: Colors.green,
                            child: Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: (total -
                                        widget.deliveryCharge -
                                        serviceCharge) <
                                    c.above
                                ? null
                                : () {
                                    coupon = c;
                                    if (Navigator.canPop(context))
                                      Navigator.pop(context);
                                  },
                          ),
                        )))
                    .toList()));
      }
      setState(() {});
    } else if (Navigator.canPop(context)) Navigator.pop(context);
  }

  double getDiscount(Coupon appliedCoupon) {
    if (appliedCoupon == null) return 0;
    print(appliedCoupon.discount);
    double discountAmt = (appliedCoupon.discount * total) / 100;
    if (discountAmt > appliedCoupon.limit)
      return appliedCoupon.limit;
    else
      return discountAmt;
  }

  
  Future placeOrder() async {
    if (!new RegExp(r'^[0-9]+$').hasMatch(_mobile.text)) {
      setState(() {
        mobileErrorText = 'Invalid Mobile Number';
      });
      return;
    }
    if (_mobile.text.trim().length < 10) {
      setState(() {
        mobileErrorText = 'Invalid Mobile Number';
      });
      return;
    }
    if (selectedAddress == null && Cache.orderType == 0) {
      await showDialog(
          context: context,
          builder: (context) =>
              MessageDialog(message: "Please Select a Delivery Address"));
      return;
    }
    Map<String, String> data = {
      'customerId': id,
      'vendorId': Cache.vendorId,
      'password': password,
      'items': json.encode(cart.cartItems),
      'deliveryAddress': Cache.orderType!=0? '': selectedAddress.flat +
          ", " +
          selectedAddress.colony +
          ", " +
          selectedAddress.landmark +
          ", " +
          selectedAddress.pincode,
      'mobile': _mobile.text,
      'deliveryCharge': widget.deliveryCharge.toStringAsFixed(2),
      'serviceCharge': serviceCharge.toStringAsFixed(2),
      'notes': _notes.text,
      'total': total.toStringAsFixed(2),
      'payment': 'Pending',
      'orderType': Cache.orderType.toString(),
      'customerName': customerName
    };
    if (coupon.couponId != null) {
      data.putIfAbsent('couponId', () => coupon.couponId);
    }
    int flag = Cache.orderType;
    if (Cache.orderType == 0) {
      double min = double.infinity;
      String selectMin;
      for (var key in Cache.locations.keys) {
        double dis = Geolocator.distanceBetween(
            Cache.locations[key][0],
            Cache.locations[key][1],
            double.parse(selectedAddress.lat),
            double.parse(selectedAddress.lng));
        if (dis < min) {
          min = dis;
          selectMin = key;
        }
      }
      Cache.outletId = selectMin;
      data.putIfAbsent('latitude', () => selectedAddress.lat);
      data.putIfAbsent('longitude', () => selectedAddress.lng);
    } else if (flag == 1 || flag == 2) {
      DateTime now = DateTime.now();
      DateTime date = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: now.add(Duration(days: 30)),
          helpText: 'Select Date for ' +
              (Cache.orderType == 1 ? 'Takeaway' : 'Dine-In'));
      if (date == null) flag = -1;
      TimeOfDay time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: 'Select Time for ' +
              (Cache.orderType == 1 ? 'Takeaway' : 'Dine-In'));
      if (time == null) flag = -1;
      DateTime finalTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      print(finalTime.toString());
      finalTime.subtract(Duration(minutes: 330));
      data.putIfAbsent(
          'time', () => finalTime.millisecondsSinceEpoch.toString());
    }
    if (flag == -1) return;
    String orderType = Cache.orderType == 0
        ? 'Delivery'
        : Cache.orderType == 1
            ? 'Takeaway'
            : 'Dine-In';
    data.putIfAbsent('orderType', () => orderType);
    String proceed = await payOnline(data);
    if (proceed == "FAILURE") return;
    var response = await postMap('/customer/place-order/v3', data, context);
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

  Future<String> payOnline(Map<String, String> data) async {
    int paymentMethod = -1;
    await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("Choose Payment Method"),
              children: [
                ListTile(
                    onTap: () {
                      paymentMethod = 0;
                      Navigator.pop(context);
                    },
                    leading: Icon(Icons.credit_card),
                    title: Text("Online"),
                    subtitle: Text("Credit/Debit/Wallets/UPI")),
                ListTile(
                    onTap: () {
                      paymentMethod = 1;
                      Navigator.pop(context);
                    },
                    leading: Icon(Icons.delivery_dining),
                    title: Text("Cash On Delivery"),
                    subtitle:
                        Text("Pay once your order is delivered at doorsteps")),
              ],
            ));
    if (paymentMethod == -1) return "FAILURE";
    if (paymentMethod == 1) return "SUCCESS";
    showDialog(context: context, builder: (context) => Pending());
    var response = await http
        .post('https://www.archerstack.com/payments/prod/pay-online', body: {
      "amount": total.toStringAsFixed(2),
      "customerName": customerName,
      "customerId": id,
      "mobile": _mobile.text
    });
    if (response.statusCode != 200) {
      return "FAILURE";
    }
    var response1 = await http.post(
        'https://www.archerstack.com/payments/prod/create-payment-link',
        body: {"paymentId": response.body});
    if (response1.statusCode != 200) return "FAILURE";
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PaymentView(url: response1.body, data: data)));
    return "FAILURE";
  }
}
