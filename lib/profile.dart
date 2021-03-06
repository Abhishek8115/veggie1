import 'package:url_launcher/url_launcher.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'server.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'home.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'cache.dart';

class Profile extends StatefulWidget {
  final bool newMember;
  final String name;
  final String address;
  final String mobile;
  Profile(
      {this.newMember = false,
      this.name = '',
      this.address = '',
      this.mobile = ''});
  @override
  _ProfileState createState() =>
      _ProfileState(this.name, this.address, this.mobile);
}

class _ProfileState extends State<Profile> {
  TextEditingController _name;
  TextEditingController _house, _street, _pincode, _landmark, _mobile;
  String houseError, streetError, pincodeError, landmarkError;
  String imagePath, nameError, mobileErrorText;
  List<String> splitted;
  _ProfileState(String name, String address, String mobile) {
    this._name = TextEditingController(text: name);
    this._mobile = TextEditingController(text: mobile);
    splitted = address.split(',');
    try {
      this._house = TextEditingController(text: splitted[0]);
      this._street = TextEditingController(text: splitted[1]);
      this._pincode = TextEditingController(text: splitted[2]);
      this._landmark = TextEditingController(text: splitted[3]);
    } catch (err) {
      this._house = TextEditingController(text: '');
      this._street = TextEditingController(text: '');
      this._pincode = TextEditingController(text: '');
      this._landmark = TextEditingController(text: '');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: (!widget.newMember)
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Cache.appBarActionsColor),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                )
              : null,
          title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Icon(Icons.mode_edit, color: Cache.appBarActionsColor),
            Text('   Profile',
                style: TextStyle(color: Cache.appBarActionsColor))
          ]),
          centerTitle: false,
        ),
        body: ListView(
          children: <Widget>[
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 50),
                child: (imagePath != null)
                    ? ClipRRect(
                        child: Image.file(
                          File(imagePath),
                          height: 100,
                          width: 100,
                        ),
                        borderRadius: BorderRadius.circular(50))
                    : ClipRRect(
                        child: FadeInImage.assetNetwork(
                          image: s3Domain +
                              Cache.vendorId + id,
                          placeholder: 'assets/no-user.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(50)),
              ),
              DropdownButton(
                  isExpanded: false,
                  hint: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(Icons.mode_edit),
                    Text('    Choose Photo',
                        style: TextStyle(color: Colors.black))
                  ]),
                  value: null,
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: 'Camera',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.photo_library,
                            color: Colors.black,
                          ),
                          Text('    Camera')
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'File',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.photo_library,
                            color: Colors.black,
                          ),
                          Text('    Gallery')
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Remove',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          Text('    Remove')
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) async {
                    if (val == 'File') {
                      imagePath = (await ImagePicker()
                              .getImage(source: ImageSource.gallery))
                          .path;
                      if (imagePath == null) return;
                      await uploadImage(imagePath);
                      return;
                    }
                    if (val == 'Camera') {
                      imagePath = (await ImagePicker()
                              .getImage(source: ImageSource.camera))
                          .path;
                      if (imagePath == null) return;
                      await uploadImage(imagePath);
                      return;
                    }
                    await removeImage();
                  }),
            ]),
            Divider(),
            Padding(
              child: TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  errorText: nameError,
                ),
                onTap: () {
                  setState(() {
                    nameError = null;
                  });
                },
              ),
              padding: EdgeInsets.all(10),
            ),
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
                  ),
                  textInputAction: TextInputAction.done,
                ),
                padding: EdgeInsets.all(10)),
            Padding(
              child: TextField(
                onChanged: (val) {
                  if (val.contains(',')) {
                    _house.text = val.replaceAll(',', '');
                  }
                },
                onTap: () {
                  setState(() {
                    houseError = null;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'House/Flat/Apartment No.',
                    errorText: houseError,
                    errorStyle: TextStyle(color: Colors.red)),
                controller: _house,
                maxLines: 1,
              ),
              padding: EdgeInsets.all(10),
            ),
            Padding(
              child: TextField(
                onChanged: (val) {
                  if (val.contains(',')) {
                    _street.text = val.replaceAll(',', '');
                  }
                },
                onTap: () {
                  setState(() {
                    streetError = null;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Street/Locality/Colony',
                    errorText: streetError,
                    errorStyle: TextStyle(color: Colors.red)),
                controller: _street,
                maxLines: 1,
              ),
              padding: EdgeInsets.all(10),
            ),
            Padding(
              child: TextField(
                onChanged: (val) {
                  if (val.contains(',')) {
                    _pincode.text = val.replaceAll(',', '');
                  }
                },
                onTap: () {
                  setState(() {
                    pincodeError = null;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Pincode',
                    errorText: pincodeError,
                    errorStyle: TextStyle(color: Colors.red)),
                controller: _pincode,
                maxLines: 1,
              ),
              padding: EdgeInsets.all(10),
            ),
            Padding(
              child: TextField(
                onChanged: (val) {
                  if (val.contains(',')) {
                    _landmark.text = val.replaceAll(',', '');
                  }
                },
                onTap: () {
                  setState(() {
                    landmarkError = null;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Landmark',
                    errorText: landmarkError,
                    errorStyle: TextStyle(color: Colors.red)),
                controller: _landmark,
                maxLines: 1,
              ),
              padding: EdgeInsets.all(10),
            ),
            SimpleBtn(
                backColor: Cache.appBarColor,
                onPressed: () async {
                  await saveDetails();
                },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text((widget.newMember)
                        ? 'Save Details'
                        : 'Update Details'))),
            Padding(padding: EdgeInsets.all(20)),
            DeveloperContact()
          ],
        ));
  }

  Future uploadImage(String path) async {
    showDialog(context: context, builder: (context) => PendingDialog());
    await FlutterImageCompress.compressAndGetFile(
        path, Directory.systemTemp.path + "/ctshop.jpeg",
        minWidth: 480, minHeight: 480, quality: 80);
    path = Directory.systemTemp.path + "/ctshop.jpeg";
    Map<String, String> map = {
      'customerId': id,
      'password': password,
      'vendorId': Cache.vendorId
    };
    String body = json.encode(map);
    var response = await upload('/upload-profile-picture', body, path, context);
    if (response.statusCode == 200) {
      if (imageCache != null) imageCache.clear();
      if (Navigator.canPop(context)) Navigator.pop(context);
      setState(() {});
    }
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future removeImage() async {
    showDialog(context: context, builder: (context) => PendingDialog());
    Map<String, String> map = {
      'customerId': id,
      'password': password,
      'vendorId': Cache.vendorId
    };
    var response =
        await postMap('/customer/remove-profile-picture', map, context);
    if (response.statusCode == 200) {
      imageCache.clear();
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future saveDetails() async {
    if (_name.text.trim().length <= 0) {
      setState(() {
        nameError = 'Please enter a name';
      });
      return;
    }
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
    if (_house.text.trim().length == 0) {
      setState(() {
        houseError = 'Invalid Input';
      });
      return;
    }
    if (_street.text.trim().length == 0) {
      setState(() {
        streetError = 'Invalid Input';
      });
      return;
    }
    if (_pincode.text.trim().length == 0) {
      setState(() {
        pincodeError = 'Invalid Input';
      });
      return;
    }
    if (_landmark.text.trim().length == 0) {
      setState(() {
        landmarkError = 'Invalid Input';
      });
      return;
    }
    var response = await postMap(
        '/customer/update-details',
        {
          'customerId': id,
          'password': password,
          'name': _name.text.trim(),
          'address': _house.text.trim() +
              ', ' +
              _street.text.trim() +
              ', ' +
              _pincode.text.trim() +
              ', ' +
              _landmark.text.trim(),
          'mobile': _mobile.text
        },
        context);
    if (response.statusCode == 200) {
      if (widget.newMember) {
        File config = new File(
            (await getApplicationDocumentsDirectory()).path + '/config');
        config.writeAsStringSync(
            id + '-' + (int.parse(password) * 1024).toString());
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
    }
  }
}

class DeveloperContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            //border: Border.all(color: Colors.grey)
            ),
        margin: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.all(4)),
            Text('Developed By : ArcherStack Private Limited',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Image.network(
                'https://www.archerstack.com/static/webicons/As- 128.png',
                height: 64,
                width: 64,
                fit: BoxFit.fill),
            Padding(padding: EdgeInsets.all(8)),
            InkWell(
              child:
                  Text('Visit Website', style: TextStyle(color: Colors.blue)),
              onTap: () {
                launch('https://cts.archerstack.com');
              },
            )
          ],
        ));
  }
}
