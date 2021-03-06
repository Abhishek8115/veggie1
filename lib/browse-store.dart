import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'cart.dart';
import 'models.dart';
import 'package:flutter/material.dart';
import 'server.dart';
import 'widgets.dart';
import 'cache.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'package:google_fonts/google_fonts.dart';

Cart cart = Cart();
_AddToCartMenuState menuState;

bool searching = false;
List<StoreItem> searchedItems = [];
CartButtonFlat cbtn = CartButtonFlat();
List<StoreItem> sectionItems = [];
Map<String, _ItemViewState> itemViewState = {};

Future showCart(BuildContext context) async {
  if (cart.cartItems.length == 0) {
    await showDialog(
        context: context,
        builder: (context) => MessageDialog(message: "Your cart is empty"));
    if (Navigator.canPop(context)) Navigator.pop(context);
    return;
  }
  showDialog(context: context, builder: (context) => Pending());
  var response = await postMap(
      '/customer/get-charges',
      {
        'customerId': id,
        'password': password,
        'vendorId': Cache.vendorId,
        'orderType': Cache.orderType.toString()
      },
      context);
  if (response.statusCode == 200) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    var decoded = json.decode(response.body) as Map;
    String mobile = decoded['Mobile'] == null ? '' : decoded['Mobile'];
    List<Address> savedAddresses =
        (decoded['Addresses'] as List).map((a) => Address.fromJson(a)).toList();
    double dc = decoded['DeliveryCharge'] == null
        ? null
        : double.tryParse(decoded['DeliveryCharge'].toString());
    double percent = decoded['PercentCharge'] == null
        ? null
        : double.tryParse(decoded['PercentCharge'].toString());
    double constant = decoded['Constant'] == null
        ? null
        : double.tryParse(decoded['Constant'].toString());
    if (dc == null || percent == null || constant == null) {
      await showDialog(
          context: context,
          builder: (context) =>
              MessageDialog(message: "Something went wrong. Try again"));
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CartView(
                  mobile: mobile,
                  savedAddresses: savedAddresses,
                  deliveryCharge: dc,
                  percentCharge: percent,
                  constant: constant,
                )));
  } else if (Navigator.canPop(context)) Navigator.pop(context);
}

class StoreDetails extends StatefulWidget {
  final BrowseStore store;
  StoreDetails({@required this.store});
  @override
  _StoreDetailsState createState() => _StoreDetailsState();
}

TextEditingController search = TextEditingController();

class _StoreDetailsState extends State<StoreDetails> {
  _StoreDetailsState() {
    itemViews = {};
    if (!searching) {
      for (var item in sectionItems) {
        itemViews.putIfAbsent(
            item.itemId, () => ItemView(key: UniqueKey(), item: item));
      }
    } else {
      for (var item in searchedItems) {
        itemViews.putIfAbsent(
            item.itemId, () => ItemView(key: UniqueKey(), item: item));
      }
    }
    cbtn = CartButtonFlat();
  }
  int sortSelected = 0;
  FocusScopeNode textNode = FocusScopeNode();
  Map<String, ItemView> itemViews;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: screenWidth,
              ),
              Positioned(
                left: 10,
                top: 10,
                width: screenWidth - 20,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon:
                        Icon(Icons.arrow_back, color: Cache.appBarActionsColor),
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                  ),
                  Container(
                    child: getSearchTextBoxWidget(),
                    width: screenWidth - 120,
                  )
                ]),
              ),
              Positioned(right: 10, top: 10, child: getSortWidget()),
              Positioned(
                  top: 60,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 120,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 120,
                      child: screenWidth > 720
                          ? GridView.builder(
                              itemCount: searching
                                  ? searchedItems.length
                                  : sectionItems.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 4,
                                crossAxisCount: 2,
                              ),
                              itemBuilder: (context, index) {
                                StoreItem it = searching
                                    ? searchedItems[index]
                                    : sectionItems[index];
                                return itemViews[it.itemId];
                              })
                          : ListView(
                              physics: BouncingScrollPhysics(),
                              children: (searching
                                  ? searchedItems
                                      .map((it) => itemViews[it.itemId])
                                      .toList()
                                  : sectionItems
                                      .map((it) => itemViews[it.itemId])
                                      .toList())))),
              Positioned(
                  bottom: 0,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: cbtn)),
              Positioned(
                  bottom: 0,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: AddToCartMenu())),
            ],
          ),
        ));
  }

  PopupMenuButton<String> getSortWidget() {
    return PopupMenuButton(
      icon: Icon(Icons.sort, color: Cache.appBarColor),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'name',
            child: Text('Sort by Name',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: (sortSelected == 0
                        ? FontWeight.bold
                        : FontWeight.normal))),
          ),
          PopupMenuItem(
            value: 'price',
            child: Text('Sort by Price',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: (sortSelected == 1
                        ? FontWeight.bold
                        : FontWeight.normal))),
          ),
          PopupMenuItem(
            value: 'rating',
            child: Text('Sort by Rating',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: (sortSelected == 2
                        ? FontWeight.bold
                        : FontWeight.normal))),
          ),
          PopupMenuItem(
            value: 'discount',
            child: Text('Sort by Discount',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: (sortSelected == 3
                        ? FontWeight.bold
                        : FontWeight.normal))),
          ),
        ];
      },
      onSelected: (val) {
        if (widget.store.storeId == '1234') return;
        if (val == 'name' && sortSelected == 0) return;
        if (val == 'price' && sortSelected == 1) return;
        if (val == 'rating' && sortSelected == 2) return;
        if (val == 'discount' && sortSelected == 3) return;
        if (val == 'name')
          sortSelected = 0;
        else if (val == 'price')
          sortSelected = 1;
        else if (val == 'rating')
          sortSelected = 2;
        else
          sortSelected = 3;
        if (searching) {
          if (val == 'name')
            searchedItems.sort((a, b) => a.header.compareTo(b.header));
          else if (val == 'price')
            searchedItems.sort((a, b) =>
                double.parse(a.price).compareTo(double.parse(b.price)));
          else if (val == 'rating')
            searchedItems.sort((a, b) => a.rating.compareTo(b.rating) * -1);
          else if (val == 'discount')
            searchedItems.sort((a, b) =>
                -1 *
                double.parse(a.discount).compareTo(double.parse(b.discount)));
        } else {
          if (val == 'name')
            sectionItems.sort((a, b) => a.header.compareTo(b.header));
          else if (val == 'price')
            sectionItems.sort((a, b) =>
                double.parse(a.price).compareTo(double.parse(b.price)));
          else if (val == 'rating')
            sectionItems.sort((a, b) => a.rating.compareTo(b.rating) * -1);
          else if (val == 'discount')
            sectionItems.sort((a, b) =>
                -1 *
                double.parse(a.discount).compareTo(double.parse(b.discount)));
        }
        setState(() {});
      },
    );
  }

  TextField getSearchTextBoxWidget() {
    return TextField(
        style: TextStyle(color: Cache.appBarActionsColor),
        cursorColor: Cache.appBarActionsColor,
        textInputAction: TextInputAction.search,
        onEditingComplete: () {
          if (search.text.trim().length == 0) {
            setState(() {
              searching = false;
              searchedItems.clear();
            });
          } else {
            searchedItems.clear();
            String p = search.text.trim().toLowerCase();
            for (var item in sectionItems) {
              String t = item.header.toLowerCase();
              if (t.contains(p)) searchedItems.add(item);
            }
            setState(() {
              searching = true;
            });
          }
        },
        controller: search,
        focusNode: textNode,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(2),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide:
                  BorderSide(color: Cache.appBarActionsColor, width: 1)),
          labelText: 'Search ' + widget.store.businessName,
          labelStyle: TextStyle(color: Cache.appBarActionsColor),
          suffixIcon: (!searching)
              ? Icon(Icons.search, color: Cache.appBarColor)
              : IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.close, size: 20, color: Cache.appBarColor),
                  onPressed: () {
                    if (widget.store.storeId == '1234') return;
                    search.clear();
                    setState(() {
                      searching = false;
                    });
                  }),
          fillColor: Colors.transparent,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1)),
        ));
  }
}

class CartButtonFlat extends StatefulWidget {
  final _CartButtonFlatState state = _CartButtonFlatState();
  @override
  _CartButtonFlatState createState() => this.state;
}

class _CartButtonFlatState extends State<CartButtonFlat> {
  int itemCount = 0;
  @override
  Widget build(BuildContext context) {
    itemCount = cart.cartItems.length;
    double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
        padding: EdgeInsets.all(0),
        child: FlatButton(
            disabledColor: Colors.grey,
            disabledTextColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(16),
            child: Text(
                'View Cart ' +
                    (itemCount == 0
                        ? ''
                        : ('( ' + itemCount.toString() + ' items)')),
                style: TextStyle(color: Colors.white)),
            color: itemCount == 0 ? Colors.grey : Cache.appBarColor,
            onPressed: itemCount == 0
                ? null
                : () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    showCart(homeContext);
                  }),
        duration: Duration(milliseconds: 300),
        width: itemCount == 0 ? 200 : screenWidth);
  }
}

class ToggleBtn extends StatefulWidget {
  final bool showDeleteOption;
  final String cartItemId;
  final State targetState;
  final ToggleBtnState state = ToggleBtnState();
  ToggleBtn({this.showDeleteOption = false, this.cartItemId, this.targetState});
  @override
  ToggleBtnState createState() => this.state;
}

class ToggleBtnState extends State<ToggleBtn> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.green[100],
            border: Border.all(width: 0, color: Colors.white)),
        margin: EdgeInsets.all(4),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(' - ', style: TextStyle(color: Colors.black)),
                ),
                onTap: () {
                  decremented();
                },
              ),
              Text(quantity.toString(), style: TextStyle(color: Colors.black)),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(' + ', style: TextStyle(color: Colors.black)),
                ),
                onTap: () {
                  incremented();
                },
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween));
  }

  void decremented() {
    if (quantity == 0) return;
    if (quantity == 1 && !widget.showDeleteOption)
      return;
    else {
      setState(() {
        if (widget.cartItemId != null && quantity == 1)
          cart.removeFromCart(widget.cartItemId);
        quantity--;
      });
      if (widget.targetState != null) widget.targetState.setState(() {});
    }
  }

  void incremented() async {
    setState(() {
      quantity++;
    });
    if (widget.targetState != null) widget.targetState.setState(() {});
  }
}

class ItemView extends StatefulWidget {
  final StoreItem item;
  ItemView({Key key, @required this.item}) : super(key: key);
  @override
  _ItemViewState createState() {
    itemViewState.remove(item.itemId);
    itemViewState.putIfAbsent(item.itemId, () => _ItemViewState(this.item));
    return itemViewState[item.itemId];
  }
}

class _ItemViewState extends State<ItemView> {
  _ItemViewState(StoreItem item) {
    this.item = item;
    sizes = [];
    crusts = [];
    if (this.item.variations != null) {
      for (var v in this.item.variations) {
        try {
          int i = v.name.indexOf(' ');
          String s = v.name.substring(0, i);
          if (!sizes.contains(s)) sizes.add(s);
          String c = v.name.substring(i + 1);
          if (!crusts.contains(c)) crusts.add(c);
        } catch (err) {
          sizes.clear();
          crusts.clear();
          break;
        }
      }
    }
  }
  StoreItem item;
  String chosenVariation;
  List<String> crusts, sizes, chosenVariations = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double price = chosenVariation == null
        ? double.parse(item.price)
        : item.variations
            .where(
              (variation) => variation.name == chosenVariation,
            )
            .first
            .price;
    double discount = chosenVariation == null
        ? double.parse(item.discount)
        : item.variations
            .where((variation) => variation.name == chosenVariation)
            .first
            .discount;
    if (chosenVariation != null) {
      chosenVariations.remove(chosenVariation);
      chosenVariations.insert(0, chosenVariation);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(

        // choose the best one above khel lena border aur color me se phrr usko umcommenty krr dena chuip maar k
        // decoration:BoxDecoration(
        //   border: Border.all(color: Colors.black54, width: 1)
        // ),
        //color: Colors.grey[200],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Container(
                height: 100,
                width: 100,
                
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  )              
                ),  
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(10),
              //   child: FadeInImage.assetNetwork(
              //       image: s3Domain + item.itemId,
              //       placeholder: 'assets/no-image.png',
              //       width: 140,
              //       height: 140,
              //       //fit: BoxFit.fill
              //     ),
              // ),
            ),
            // Positioned(
            //     top: 10,
            //     left: 0,
            //     width: screenWidth,
            //     height: (screenWidth) / 2,
            //     child: ClipRRect(
            //         borderRadius: BorderRadius.circular(2),
            //         child: InkWell(
            //           onTap: () {
            //             Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                     builder: (context) => ItemDetails(item: item)));
            //           },
            //           child: CachedImage(
            //               id: item.itemId,
            //               width: screenWidth,
            //               height: (screenWidth) / 2),
            //         ))),
            // Container(
            //   color: Colors.purple,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[
            //       Padding(
            //         padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
            //         child: getItemContentWidget(),
            //       ),
            //       // Padding(
            //       //  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            //       //   child: Container(color: Colors.black,child: getPriceWidget(discount, price))
            //       // ),                
            //       Positioned(
            //         bottom: 30,
            //         child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               getAddToCartButton(),
            //             ]),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                //color: Colors.purple,
                //height: MediaQuery.of(context).size.height*0.18,
                width: screenWidth*0.6,
                child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 00, 0, 0),
                      child: getItemContentWidget(),
                    ),
                Container(
                  //height: 50,
                  //color: Colors.red,
                  child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 170, 0),
                  child: 
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        discount > 0
                            ? Text(Cache.currency + ' ' + price.toStringAsFixed(2),
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough))
                            : Padding(padding: EdgeInsets.all(0)),
                        Text(
                            Cache.currency +
                                ' ' +
                                (price - discount).toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        Padding(padding: EdgeInsets.all(8)),
                      ],
                    ),
                  ),
                ), 
                Container(
                  //color: Colors.white,
                  child:getAddToCartButton()
                )
                ],
              )
            ),
          )
        ],
      ),
    ),
  );
}

  Row getItemContentWidget() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //color: Colors.grey,
              height: 65,
              width: 187,
              padding: EdgeInsets.only(top: 2, left: 2, right: 2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(item.header,
                            style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold
                            ),
                            maxLines: 1),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: getAddToFavoriteWidget(context),
                            )
                      ],
                      
                    ),
                    Text(item.description == null ? '' : item.description,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        maxLines: 2),
                    //Padding(padding: EdgeInsets.all(4)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 00, 0, 0),
                      child: getStars(item.rating),
                    )
                  ])),
          
        ]);
  }

  Widget getAddToFavoriteWidget(BuildContext context) {
    return InkWell(
      child: Icon(
          Cache.favorites.contains(item.itemId)
              ? Icons.favorite
              : Icons.favorite_outline,
          color:
              Cache.favorites.contains(item.itemId) ? Colors.red : Colors.black,
          size: 25),
      onTap: () {
        if (Cache.favorites.contains(item.itemId)) {
          Cache.favorites.remove(item.itemId);
          setState(() {});
          postMap(
              '/customer/remove-from-favorites',
              {'customerId': id, 'password': password, 'itemId': item.itemId},
              context);
        } else {
          Cache.favorites.add(item.itemId);
          setState(() {});
          postMap(
              '/customer/add-to-favorites',
              {'customerId': id, 'password': password, 'itemId': item.itemId},
              context);
        }
      },
    );
  }

  Transform getPriceWidget(double discount, double price) {
    return Transform.rotate(
        angle: -3.14 / 4,
        child: Container(
            width: 80,
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                discount > 0
                    ? Text(Cache.currency + ' ' + price.toStringAsFixed(2),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough))
                    : Padding(padding: EdgeInsets.all(0)),
                Text(
                    Cache.currency +
                        ' ' +
                        (price - discount).toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Padding(padding: EdgeInsets.all(8)),
              ],
            ),
            decoration: BoxDecoration(
                color: Color(0x50000000),
                borderRadius: BorderRadius.circular(50))));
  }

  Widget getAddToCartButton() {
    return InkWell(
      onTap: () async {
        menuState.item = item;
        menuState.showContainer = true;
        menuState.setState(() {});
      },
      child: Text('Add To Cart',
          textAlign: TextAlign.center, 
          style: GoogleFonts.nunitoSans(
            color:Colors.red,
            fontWeight: FontWeight.w800
          )),
    );
  }

  Widget getStars(double rating) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star,
                size: 20,
                color: rating >= 1 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 20,
                color: rating >= 2 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 20,
                color: rating >= 3 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 20,
                color: rating >= 4 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 20,
                color: rating >= 5 ? Colors.yellow : Colors.transparent),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text("(" + rating.toStringAsFixed(1) + ")",
                  style: GoogleFonts.lato(
                      color: Colors.black, textStyle: TextStyle(fontSize: 12))),
            ),
          ]),
          //getAddToFavoriteWidget(context)
        ]);
  }
}

class AddToCartMenu extends StatefulWidget {
  @override
  _AddToCartMenuState createState() {
    menuState = _AddToCartMenuState();
    return menuState;
  }
}

class _AddToCartMenuState extends State<AddToCartMenu> {
  List<String> sizes = [];
  Map<String, String> crusts = {};
  String chosenVariation, chosenSize, chosenCrust;
  StoreItem item;
  bool showContainer = false;
  double total = 0;
  int quantity = 1;
  List<String> chosenCustomizations = [], customizations = [];
  bool splitIntoSizeAndCrust = true;
  void reset() {
    sizes.clear();
    crusts.clear();
    chosenVariation = chosenSize = chosenCrust = null;
    item = null;
    chosenCustomizations.clear();
    customizations.clear();
    total = 0;
    quantity = 1;
  }

  @override
  Widget build(BuildContext context) {
    total = 0;
    sizes.clear();
    crusts.clear();
    customizations.clear();
    double height = 1;
    if (!showContainer)
      height = 1;
    else if (item.variations == null &&
        (item.customizations == null || item.customizations.isEmpty))
      height = 150;
    else if (splitIntoSizeAndCrust)
      height = MediaQuery.of(context).size.height - 200;
    else
      height = 300;
    return AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: MediaQuery.of(context).size.width - 8,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: !showContainer
            ? Card()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('    ' + item.header,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            reset();
                            setState(() {
                              showContainer = false;
                            });
                          })
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: ListView(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      children: [
                        chooseSizesMenu(),
                        chooseCrustsMenu(),
                        chooseToppingsMenu(),
                      ],
                    ),
                  ),
                  getToggleAndAddToCartBtn()
                ],
              ));
  }

  Widget chooseSizesMenu() {
    List<Widget> children = [];
    if (item.variations == null) {
      chosenSize = '';
      return Card();
    }
    for (var v in item.variations) {
      try {
        int i = v.name.indexOf(' ');
        String s = v.name.substring(0, i);
        if (!sizes.contains(s)) sizes.add(s);
      } catch (err) {
        splitIntoSizeAndCrust = false;
        chosenSize = '';
        sizes.clear();
      }
    }

    if (sizes.isNotEmpty && chosenSize == null) {
      chosenSize = sizes.first;
    }

    if (sizes.isNotEmpty)
      children.add(Padding(
          child: Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
          padding: EdgeInsets.all(4)));
    children.addAll(sizes.map((size) => InkWell(
        onTap: () {
          chosenSize = size;
          chosenCustomizations.clear();
          setState(() {});
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(size),
              ),
              Card(
                  color: size == chosenSize ? Colors.green : Colors.white,
                  shape: CircleBorder(),
                  child: Icon(Icons.check, color: Colors.white, size: 20))
            ]))));
    children.add(Divider());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget chooseCrustsMenu() {
    List<Widget> children = [];
    if (item.variations == null) return Card();
    for (var v in item.variations) {
      if (splitIntoSizeAndCrust) {
        if (v.name.contains(chosenSize)) {
          crusts.putIfAbsent(
              v.name.substring(v.name.indexOf(' ') + 1),
              () =>
                  Cache.currency +
                  " " +
                  (v.price - v.discount).toStringAsFixed(2));
        }
      } else {
        crusts.putIfAbsent(
            v.name,
            () =>
                Cache.currency +
                " " +
                (v.price - v.discount).toStringAsFixed(2));
      }
    }
    if (crusts.isNotEmpty && chosenCrust == null) {
      chosenCrust = crusts.keys.first;
    }
    if (crusts.isNotEmpty)
      children.add(Padding(
          child: Text(splitIntoSizeAndCrust ? "Crusts" : "Type",
              style: TextStyle(fontWeight: FontWeight.bold)),
          padding: EdgeInsets.all(4)));
    children.addAll(crusts.keys.map((e) => InkWell(
          onTap: () {
            setState(() {
              chosenCrust = e;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(e),
              ),
              Spacer(),
              Text(crusts[e],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green[700])),
              Card(
                  margin: EdgeInsets.all(8),
                  shape: CircleBorder(),
                  color: e == chosenCrust ? Colors.green : Colors.white,
                  child: Icon(Icons.check, color: Colors.white, size: 20))
            ],
          ),
        )));

    children.add(Divider());
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget chooseToppingsMenu() {
    if (item.customizations == null) return Card();
    for (var c in item.customizations.keys) {
      if (c.contains(chosenSize)) {
        customizations.add(c);
      }
    }
    List<Widget> children = [];
    if (customizations.isNotEmpty)
      children.add(Padding(
          child: Text(chosenSize == '' ? "Choose" : "Extra Toppings & Add-ons",
              style: TextStyle(fontWeight: FontWeight.bold)),
          padding: EdgeInsets.all(4)));
    children.addAll(customizations.map((e) => InkWell(
          onTap: () {
            setState(() {
              chosenCustomizations.remove(e);
              customizations.add(e);
            });
          },
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 120,
                padding: const EdgeInsets.all(4.0),
                child: Text(e),
              ),
              Spacer(),
              Text(
                  item.customizations[e] <= 0
                      ? ''
                      : Cache.currency +
                          " " +
                          item.customizations[e].toStringAsFixed(2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green[700])),
              Checkbox(
                  activeColor: Colors.green,
                  value: chosenCustomizations.contains(e),
                  onChanged: (val) {
                    if (item.customizations[e] <= 0)
                      chosenCustomizations.clear();
                    if (val) {
                      chosenCustomizations.remove(e);
                      chosenCustomizations.add(e);
                      setState(() {});
                    } else {
                      chosenCustomizations.remove(e);
                      setState(() {});
                    }
                  })
            ],
          ),
        )));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget getToggleAndAddToCartBtn() {
    if (item.customizations != null) {
      for (var c
          in item.customizations.keys.where((e) => e.contains(chosenSize))) {
        if (chosenCustomizations.contains(c)) total += item.customizations[c];
      }
    }
    if (item.variations != null) {
      VariationItem vi = item.variations
          .where((e) => e.name.contains(chosenSize))
          .where((e) => e.name.contains(chosenCrust))
          .first;
      total += vi.price - vi.discount;
      total *= quantity;
      chosenVariation = vi.name;
    } else {
      total += double.parse(item.price) - double.parse(item.discount);
      total *= quantity;
    }
    List<String> data = getCartItemsDescriptionAndPrice(
        item, quantity, chosenVariation, chosenCustomizations);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Container(
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
              border: Border.all(width: 0, color: Colors.white)),
          margin: EdgeInsets.all(4),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.remove_circle)),
                  onTap: () {
                    if (quantity == 1) return;
                    setState(() {
                      quantity--;
                    });
                  },
                ),
                Text(quantity.toString(),
                    style: TextStyle(color: Colors.black)),
                InkWell(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.add_circle)),
                  onTap: () {
                    setState(() {
                      quantity++;
                    });
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween)),
      FlatButton(
          color: Colors.green,
          onPressed: () {
            int q = quantity;
            cart.addToCart(CartItem(
                item.itemId,
                DateTime.now().millisecondsSinceEpoch.toString(),
                q,
                data[0],
                data[1],
                item.header));
            reset();
            cbtn.state.setState(() {});
            setState(() {
              showContainer = false;
            });
          },
          child: Text(
              'Add (' + Cache.currency + " " + total.toStringAsFixed(2) + ')',
              style: TextStyle(color: Colors.white)))
    ]);
  }
}

List<String> getCartItemsDescriptionAndPrice(StoreItem item, int quantity,
    String variation, List<String> customizations) {
  double tot = 0;
  String sub = "";
  if (item.variations == null) {
    double netPrice = double.parse(item.price) - double.parse(item.discount);
    netPrice *= quantity;
    sub = sub +
        quantity.toString() +
        ' x ' +
        item.header +
        " @ " +
        Cache.currency +
        ' ' +
        netPrice.toStringAsFixed(2) +
        '\n';
    tot = netPrice;
  } else {
    VariationItem v = item.variations.firstWhere(
        (element) => element.name == variation,
        orElse: () => VariationItem(
            "", double.parse(item.price), double.parse(item.discount)));
    double netPrice = quantity * (v.price - v.discount);
    sub = sub +
        quantity.toString() +
        ' x ' +
        v.name +
        " @ " +
        Cache.currency +
        " " +
        netPrice.toStringAsFixed(2) +
        "\n";
    tot = netPrice;
  }
  for (var c in customizations) {
    sub += quantity.toString() +
        " x " +
        c +
        " @ " +
        Cache.currency +
        " " +
        (item.customizations[c] * quantity).toStringAsFixed(2) +
        "\n";
    tot += (item.customizations[c] * quantity);
  }
  return [sub, tot.toStringAsFixed(2)];
}
