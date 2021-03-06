import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'server.dart';
import 'cache.dart';
import 'models.dart';
import 'browse-store.dart';

bool selecting = true;
_AddToCartMenuState smenuState;

class SelectableData {
  static int buyN = 0;
  static int getM = 0;
  static int bought = 0;
  static int got = 0;
  static String title = "";
  static String selectableId;
  static List<String> chosen = [];
  static List<String> gotten = [];
  static Map<String, List<String>> descriptions = {};
  static clear() {
    buyN = getM = bought = got = 0;
    selectableId = null;
    chosen.clear();
    gotten.clear();
    descriptions.clear();
  }

  static initialize(int bN, int gM, int b, int g, String s, String t) {
    buyN = bN;
    getM = gM;
    bought = b;
    got = g;
    title = t;
    selectableId = s;
  }
}

_SelectablesState state;

class Selectables extends StatefulWidget {
  final List<StoreItem> purchaseItems;
  final List<StoreItem> choosableItems;
  Selectables({@required this.purchaseItems, @required this.choosableItems});
  @override
  _SelectablesState createState() {
    state = _SelectablesState(this.purchaseItems, this.choosableItems);
    return state;
  }
}

class _SelectablesState extends State<Selectables> {
  List<StoreItem> selected = [];
  List<StoreItem> chosen = [];
  List<StoreItem> purchaseItems, choosableItems;
  List<Widget> sItems;
  _SelectablesState(List<StoreItem> pl, List<StoreItem> c) {print("const");
    purchaseItems = pl;
    choosableItems = c;
    selecting = true;
  }
  @override
  Widget build(BuildContext context) {
    if (selected.length < SelectableData.buyN) selecting = true;
    else if(chosen.length<SelectableData.getM) selecting = false;
    else if(selected.length>SelectableData.buyN || chosen.length>SelectableData.getM) 
	{
		selected.clear();
		chosen.clear();
	}
    int c = SelectableData.bought + SelectableData.got;
    int d = SelectableData.buyN + SelectableData.getM;
    String s;
    if (c == 0)
      s = '1st';
    else if (c == 1)
      s = '2nd';
    else if (c == 2)
      s = '3rd';
    else
      s = (c + 1).toString() + 'th';
    sItems = selected.map((e) => Selection(item: e)).toList();
    for (var e in chosen) sItems.add(Selection(item: e));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(c == d ? 'Back' : ('Choose ' + s),
            style: TextStyle(color: Cache.appBarActionsColor)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Cache.appBarActionsColor),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: !selecting
                ? this.choosableItems.length
                : this.purchaseItems.length,
            itemBuilder: (context, index) {
              StoreItem item = !selecting
                  ? this.choosableItems[index]
                  : this.purchaseItems[index];
              return ItemView(item: item, key: UniqueKey());
            },
          )),
          AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.green[800],
                Colors.green[600],
                Colors.green[400]
              ])),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(sItems.length == 0 ? 0 : 4),
              height: sItems.length == 0 ? 0 : 100,
              child:
                  ListView(scrollDirection: Axis.horizontal, children: sItems)),
          InkWell(
              child: Container(
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  child: Text('Add to Cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                  color: (SelectableData.buyN == SelectableData.bought &&
                          SelectableData.getM == SelectableData.got)
                      ? Cache.appBarColor
                      : Colors.grey),
              onTap: () {
                addToCart();
              }),
          AddToCartMenu()
        ],
      ),
    );
  }

  void addToCart() {
    String d = "";
    double total = 0;
    for (var key in SelectableData.descriptions.keys) {
      d += SelectableData.descriptions[key].first;
      total += chosen.where((e)=> e.itemId==key).isNotEmpty? 0 : double.parse(SelectableData.descriptions[key][1]);
    }
    var ct = CartItem(
        SelectableData.selectableId,
        DateTime.now().millisecondsSinceEpoch.toString(),
        1,
        d,
        total.toStringAsFixed(2),
        SelectableData.title);
     cart.cartItems.add(ct);
    if(Navigator.canPop(context)) Navigator.pop(context);
  }
}

class ItemView extends StatefulWidget {
  final StoreItem item;
  ItemView({Key key, @required this.item}) : super(key: key);
  @override
  _ItemViewState createState() => _ItemViewState(this.item);
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
    return Container(
      child: Column(
        children: [
          Stack(children: [
            Container(
                width: screenWidth, height: 300, margin: EdgeInsets.all(0)),
            Positioned(
                top: 0,
                left: 0,
                width: screenWidth,
                height: (screenWidth) / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CachedImage(
                      id: item.itemId,
                      width: screenWidth,
                      height: (screenWidth) / 2),
                )),
            Positioned(
                left: 0,
                width: 80,
                height: 80,
                child: getPriceWidget(discount, price)),
            Positioned(
                top: ((screenWidth) / 2),
                left: 10,
                width: (screenWidth - 24),
                height: 100,
                child: getItemContentWidget()),
            Positioned(
              bottom: 30,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getAddToCartButton(),
                  ]),
            ),
          ]),
        ],
      ),
    );
  }

  Row getItemContentWidget() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 100,
              width: 220,
              padding: EdgeInsets.only(top: 2, left: 2, right: 2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.header,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 2),
                    Text(item.description == null ? '' : item.description,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        maxLines: 2),
                    Padding(padding: EdgeInsets.all(4)),
                  ])),
          getStars(item.rating)
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
          size: 18),
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
        smenuState.item = item;
        smenuState.showContainer = true;
        smenuState.setState(() {});
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Select',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget getStars(double rating) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star,
                size: 17,
                color: rating >= 1 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 17,
                color: rating >= 2 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 17,
                color: rating >= 3 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 17,
                color: rating >= 4 ? Colors.yellow : Colors.transparent),
            Icon(Icons.star,
                size: 17,
                color: rating >= 5 ? Colors.yellow : Colors.transparent),
            Text("(" + rating.toStringAsFixed(1) + ")",
                style: TextStyle(fontSize: 12)),
          ]),
          getAddToFavoriteWidget(context)
        ]);
  }
}

class AddToCartMenu extends StatefulWidget {
  @override
  _AddToCartMenuState createState() {
    smenuState = _AddToCartMenuState();
    return smenuState;
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
    if(!showContainer) height = 1;
    else if(item.variations==null && (item.customizations==null || item.customizations.isEmpty))
	height=150;
    else if(splitIntoSizeAndCrust)
	height= MediaQuery.of(context).size.height - 200;
    else height = 300;
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
    if (item.variations == null) {chosenSize='';return Card();}
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
              Text(item.customizations[e]<=0? '': 
                  Cache.currency +
                      " " +
                      item.customizations[e].toStringAsFixed(2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green[700])),
              Checkbox(
                  activeColor: Colors.green,
                  value: chosenCustomizations.contains(e),
                  onChanged: (val) {
                    if(item.customizations[e]<=0) chosenCustomizations.clear();
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
    return FlatButton(
        color: Colors.green,
        onPressed: () {
          selected();
          reset();
          setState(() {
            showContainer = false;
          });
        },
        child: Text(
            selecting
                ? 'Add (' +
                    Cache.currency +
                    " " +
                    total.toStringAsFixed(2) +
                    ')'
                : 'Add',
            style: TextStyle(color: Colors.white)));
  }

  void selected() {
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
      total += (selecting)? vi.price - vi.discount : 0;
      total *= quantity;
      chosenVariation = vi.name;
    } else {
      total += selecting? (double.parse(item.price) - double.parse(item.discount) ): 0;
      total *= quantity;
    }
    String newId =
        item.itemId + DateTime.now().millisecondsSinceEpoch.toString();
    List<String> data = getCartItemsDescriptionAndPrice(
        item, 1, chosenVariation, chosenCustomizations);
    SelectableData.descriptions.putIfAbsent(newId, () => data);
    StoreItem newItem = StoreItem(
      item.header,
      item.price,
      item.discount,
      newId,
      item.description,
      item.sectionName,
      item.rating,
      item.variations,
      item.customizations,
      item.storeId,
    );
    if (selecting) {
      SelectableData.bought++;
      state.selected.add(newItem);
      SelectableData.chosen.add(newId);
    } else {
      if(state.chosen.length>=SelectableData.getM) return;
      SelectableData.got++;
      state.chosen.add(newItem);
      SelectableData.gotten.add(newId);
    }
    state.setState(() {});
  }
}


class Selection extends StatelessWidget {
  final StoreItem item;
  Selection({@required this.item});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          margin: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                      child: FadeInImage.assetNetwork(
                          image: s3Domain + item.itemId.substring(0, 24),
                          placeholder: 'assets/no-image.png',
                          height: 48,
                          width: 48,
                          fit: BoxFit.fill),
                      borderRadius: BorderRadius.circular(48)),
                ],
              ),
              Text(item.header,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                  maxLines: 2)
            ],
          )),
      Positioned(
        right: 0,
        child: InkWell(
          child: Icon(Icons.delete, color: Colors.white, size: 18),
          onTap: () {
            SelectableData.descriptions.remove(item.itemId);
            if (SelectableData.chosen.remove(item.itemId)) {
              SelectableData.bought--;
              state.selected.removeWhere((e)=> e.itemId==item.itemId);
              state.setState(() {});
            } else {
              SelectableData.got--;
              SelectableData.gotten.remove(item.itemId);
              state.chosen.removeWhere((e)=> e.itemId==item.itemId);
              state.setState(() {});
            }
          },
        ),
      )
    ]);
  }
}

Widget getStars(double rating) {
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.star,
        size: 17, color: rating >= 1 ? Colors.yellow : Colors.transparent),
    Icon(Icons.star,
        size: 17, color: rating >= 2 ? Colors.yellow : Colors.transparent),
    Icon(Icons.star,
        size: 17, color: rating >= 3 ? Colors.yellow : Colors.transparent),
    Icon(Icons.star,
        size: 17, color: rating >= 4 ? Colors.yellow : Colors.transparent),
    Icon(Icons.star,
        size: 17, color: rating >= 5 ? Colors.yellow : Colors.transparent),
    Text("(" + rating.toStringAsFixed(1) + ")", style: TextStyle(fontSize: 12))
  ]);
}
