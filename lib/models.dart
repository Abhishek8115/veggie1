import 'package:flutter/material.dart';
import 'cache.dart';

class BrowseStore {
  String businessName, deliveryCharge, storeId;
  List<StoreItem> items;
  BrowseStore(String businessName, String deliveryCharge, String storeId,
      List<StoreItem> items) {
    this.businessName = businessName;
    this.deliveryCharge = deliveryCharge;
    this.storeId = storeId;
    this.items = items;
  }

  factory BrowseStore.fromJson(Map<String, dynamic> json) {
    return BrowseStore(
        json['BusinessName'] as String,
        (json['DeliveryCharge']).toString(),
        (json['StoreId'] as String),
        ((json['Items'] as List).map((e) => StoreItem.fromJson(e)).toList()));
  }
}

class CustomerOrder {
  String orderId,
      total,
      businessName,
      status,
      deliveryAddress,
      date,
      time,
      notes,
      deliveryCharge,
      serviceCharge,
      payment,
      reasonOfCancellation,
      mobile, 
	vendorId
;
  bool rated;
  List<OrderItem> items;
  String couponCode;
  double couponDiscount;
  CustomerOrder(
      this.orderId,
      this.total,
      this.status,
      this.items,
      this.deliveryAddress,
      this.date,
      this.time,
      this.notes,
      this.businessName,
      this.deliveryCharge,
      this.serviceCharge,
      this.payment,
      this.rated,
      this.reasonOfCancellation,
      this.couponCode,
      this.couponDiscount,
      this.mobile, this.vendorId);

  factory CustomerOrder.fromJson(
      Map<String, dynamic> json, BuildContext context) {
    DateTime dateTime = DateTime.parse(json['Date'] as String)
        .add(Duration(hours: 5, minutes: 30));
    String date = dateTime.day.toString() +
        '.' +
        dateTime.month.toString() +
        '.' +
        dateTime.year.toString();
    String time = TimeOfDay.fromDateTime(dateTime).format(context);
    List<OrderItem> items = (json['Items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList();
    double cd;
    String cp;
    if (json['Coupon'] != null) {
      cd = json['Coupon']['Discount'] == null
          ? 0
          : json['Coupon']['Discount'].toDouble();
      cp = json['Coupon']['Coupon Code'];
    }
    return CustomerOrder(
        json['OrderId'],
        json['Total'].toString(),
        json['Status'],
        items,
        json['DeliveryAddress'],
        date,
        time,
        json['Notes'],
        json['BusinessName'],
        ((json['DeliveryCharge'] == null)
            ? '0'
            : json['DeliveryCharge'].toString()),
        ((json['ServiceCharge'] == null)
            ? '0'
            : json['ServiceCharge'].toString()),
        (json['Payment']==null? 'Pending': json['Payment'].toString()),
        (json['Rated'] == null ? false : true),
        (json['ReasonOfCancellation'] == null
            ? ''
            : json['ReasonOfCancellation']),
        cp,
        cd,
        json['Mobile'].toString(), json['VendorId']);
  }
}

class MiniOrder {
  String date, status, total, orderId, time;
  MiniOrder(
      String date, String status, String total, String orderId, String time) {
    this.date = date;
    this.status = status;
    this.total = total;
    this.orderId = orderId;
    this.time = time;
  }
  factory MiniOrder.fromJson(Map<String, dynamic> json, BuildContext context) {
    String date;
    DateTime d =
        DateTime.parse(json['Date']).add(Duration(minutes: 30, hours: 5));
    date =
        d.day.toString() + '.' + d.month.toString() + '.' + d.year.toString();
    return MiniOrder(date, json['Status'], json['Total'].toString(),
        json['OrderId'], TimeOfDay.fromDateTime(d).format(context));
  }
}

//Models for Vendor
class Vendor {
  String name, businessName, businessAddress, deliveryCharge;
  Vendor(String name, String businessName, String businessAddress,
      String deliveryCharge) {
    this.name = name;
    this.businessAddress = businessAddress;
    this.businessName = businessName;
    this.deliveryCharge = deliveryCharge;
  }
}

class Item {
  String itemId, price, quantity, header;
  Item(this.itemId, this.price, this.quantity, this.header);
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json['ItemId'], json['Price'].toString(),
        json['Quantity'].toString(), json['Header']);
  }
}

class StoreItem {
  String header, price, discount, itemId, description, sectionName, storeId;
  List<VariationItem> variations;
  Map<String, double> customizations;
  double rating;
  StoreItem(
      this.header,
      this.price,
      this.discount,
      this.itemId,
      this.description,
      this.sectionName,
      this.rating,
      this.variations,
      this.customizations,
      this.storeId);
  factory StoreItem.fromJson(Map<String, dynamic> json) {
    Map<String, double> ctm;
    if (json['Customizations'] != null) {
      if (json['Customizations'].keys.length > 0) {
        ctm = {};
        for (var key in json['Customizations'].keys) {
          ctm.putIfAbsent(key, () => json['Customizations'][key].toDouble());
        }
      }
    }
    return StoreItem(
        json['Header'] as String,
        (json['Price'] == null ? '0' : json['Price'].toString()),
        (json['Discount'] == null ? '0' : json['Discount'].toString()),
        json['ItemId'] as String,
        json['Description'] as String,
        (json['SectionName'] == null ? '' : json['SectionName']),
        (json['Rating'] == null ? 5.0 : json['Rating'].toDouble()),
        ((json['Variations'] == null)
            ? null
            : (json['Variations'] as List)
                .map((e) => VariationItem.fromJson(e))
                .toList()),
        ctm,
        json['StoreId'].toString());
  }
}

class CtsNotification {
  String message, time, orderId;
  CtsNotification(this.message, this.time, this.orderId);
  factory CtsNotification.fromJson(
      Map<String, dynamic> json, BuildContext context) {
    DateTime date =
        DateTime.parse(json['Date']).add(Duration(hours: 5, minutes: 30));
    String d = TimeOfDay.fromDateTime(date).format(context);
    d = d +
        ', ' +
        date.day.toString() +
        '.' +
        date.month.toString() +
        '.' +
        date.year.toString();
    return CtsNotification(
        json['Subject'], d, (json['OrderId'] == null ? '' : json['OrderId']));
  }
}

class OrderItem {
  String itemId, price, details, header;
  OrderItem(this.itemId, this.price, this.details, this.header);
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      json['ItemId'],
      json['Price'].toStringAsFixed(2),
      (json['Details'] == null ? '' : json['Details']),
      json['Header'],
    );
  }
  Map toJson() {
    return {
      "ItemId": this.itemId,
      "Price": this.price,
      "Details": this.details,
      "Header": this.header
    };
  }
}

class VariationItem {
  String name;
  double price, discount;
  VariationItem(this.name, this.price, this.discount);
  factory VariationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return VariationItem(
        json['Name'],
        (json['Price'] != null ? json['Price'].toDouble() : 0),
        (json['Discount'] != null ? json['Discount'].toDouble() : 0));
  }
}

class CartItem {
  String itemId;
  String cartItemId;
  int quantity;
  String description, price, header;
  CartItem(this.itemId, this.cartItemId, this.quantity, this.description,
      this.price, this.header);
  Map toJson() {
    return {
      "ItemId": this.itemId,
      "Price": this.price,
      "Details": this.description,
      "Header": this.header
    };
  }
}

class Coupon {
  String description, code, couponId;
  double discount, above, limit;
  Coupon(this.couponId, this.description, this.code, this.discount, this.above,
      this.limit);
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
        json['CouponId'],
        json['Description'],
        json['Code'],
        json['Discount'].toDouble(),
        json['Above'].toDouble(),
        (json['Limit'] == null ? double.infinity : json['Limit'].toDouble()));
  }
}

class Selectable {
  String selectableId;
  List<String> purchased;
  List<String> chosen;
  Selectable(this.selectableId, this.purchased, this.chosen);
  Map toJson() {
    return {
      'selectableId': this.selectableId,
      'purchased': this.purchased,
      'chosen': this.chosen
    };
  }
}

class EdvOffer {
  String selectableId, title;
  int buyN, getM;
  EdvOffer(this.selectableId, this.title, this.buyN, this.getM);
  factory EdvOffer.fromJson(Map<String, dynamic> json) {
    return EdvOffer(json['SelectableId'], json['Title'], json['BuyN'].toInt(),
        json['GetM'].toInt());
  }
}

class Cart {
  List<CartItem> cartItems = [];

  void addToCart(CartItem item) {
    cartItems.add(item);
  }

  void removeFromCart(String cartItemId) {
    cartItems.removeWhere((element) => element.cartItemId == cartItemId);
  }

  CartItem decrement(String cartItemId) {
    int i;
    for (i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        if (cartItems[i].quantity == 1) {
          cartItems.removeAt(i);
          return null;
        }
        List<String> splitted = cartItems[i].description.split('\n');
        String des = "";
        String newQuantity = (cartItems[i].quantity - 1).toString() + " x ";
        String qStr = cartItems[i].quantity.toString() + " x ";
        for (var k = 0; k < splitted.length - 1; k++) {
          String s = splitted[k];
          String p1 = newQuantity + s.substring(s.indexOf('x') + 2);
          double oldPrice = double.parse(s.substring(s.lastIndexOf(' ') + 1));
          double newPrice = oldPrice / cartItems[i].quantity;
          newPrice *= (cartItems[i].quantity - 1);
          String p2 = p1.substring(0, p1.lastIndexOf('@')) +
              '@ ' +
              Cache.currency +
              " " +
              newPrice.toStringAsFixed(2);
          des = des + p2 + "\n";
        }
        cartItems[i].description = des;
        cartItems[i].price =
            ((double.parse(cartItems[i].price) / cartItems[i].quantity) *
                    (cartItems[i].quantity - 1))
                .toStringAsFixed(2);
        cartItems[i].quantity--;
        break;
      }
    }
    return cartItems[i];
  }

  CartItem increment(String cartItemId) {
    int i;
    for (i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        List<String> splitted = cartItems[i].description.split('\n');
        String des = "";
        String newQuantity = (cartItems[i].quantity + 1).toString() + " x ";
        String qStr = cartItems[i].quantity.toString() + " x ";
        for (var k = 0; k < splitted.length - 1; k++) {
          String s = splitted[k];
          String p1 = newQuantity + s.substring(s.indexOf('x') + 2);
          double oldPrice = double.parse(s.substring(s.lastIndexOf(' ') + 1));
          double newPrice = oldPrice / cartItems[i].quantity;
          newPrice *= (cartItems[i].quantity + 1);
          String p2 = p1.substring(0, p1.lastIndexOf('@')) +
              '@ ' +
              Cache.currency +
              " " +
              newPrice.toStringAsFixed(2);
          des = des + p2 + "\n";
        }
        cartItems[i].description = des;
        cartItems[i].price =
            ((double.parse(cartItems[i].price) / cartItems[i].quantity) *
                    (cartItems[i].quantity + 1))
                .toStringAsFixed(2);
        cartItems[i].quantity++;
        break;
      }
    }
    return cartItems[i];
  }
}

class Post {
  String postId, customerName, customerId, date, status, caption;
  Post(this.postId, this.customerId, this.customerName, this.date, this.status,
      this.caption);
  factory Post.fromJson(Map<String, dynamic> json, BuildContext context) {
    DateTime d =
        DateTime.parse(json['Date'].toString()).add(Duration(minutes: 330));
    String dStr = TimeOfDay.fromDateTime(d).format(context);
    dStr += ", " +
        d.day.toString() +
        "." +
        d.month.toString() +
        "." +
        d.year.toString();
    return Post(
        json['PostId'],
        json['CustomerId'],
        json['CustomerName'],
        dStr,
        json['Status'],
        (json['Caption'] == null ? dStr : json['Caption'] + "\n" + dStr));
  }
}


class Address {
  String pincode, landmark, colony, flat, lat, lng, id;
  Address(this.pincode, this.landmark, this.colony, this.flat, this.lat,
      this.lng, this.id);
  factory Address.fromJson(Map json) {
    return Address(
        json['Pincode'],
        json['Landmark'],
        json['Colony'],
        json['Flat'],
        json['Latitude'],
        json['Longitude'],
        json['AddressId'] == null ? '' : json['AddressId']);
  }
}