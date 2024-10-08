import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:needlinc/needlinc/backend/functions/add_commas.dart';
import 'package:needlinc/needlinc/backend/functions/cross_axis_count_calculator.dart';
import 'package:needlinc/needlinc/backend/functions/format_string.dart';
import 'package:needlinc/needlinc/backend/functions/get-user-data.dart';
import 'package:needlinc/needlinc/backend/user-account/functionality.dart';
import 'package:needlinc/needlinc/shared-pages/product-details.dart';
import '../backend/user-account/upload-post.dart';
import '../client-pages/client-profile.dart';
import '../shared-pages/chat-pages/chat_screen.dart';
import '../shared-pages/construction.dart';
import '../shared-pages/market-place-post.dart';
import 'package:needlinc/needlinc/business-pages/business-main.dart';
import 'package:needlinc/needlinc/shared-pages/comments.dart';
import '../needlinc-variables/colors.dart';
import 'package:needlinc/needlinc/shared-pages/chat-pages/messages.dart';
import '../widgets/bottom-menu.dart';
import 'business-profile.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  CollectionReference marketPlacePosts =
      FirebaseFirestore.instance.collection('marketPlacePage');
  CollectionReference user = FirebaseFirestore.instance.collection('users');

  List<DocumentSnapshot> searchResults = [];
  bool isSearching = false;

  late String myUserId;
  late String myUserName;
  late String myProfilePicture;
  late String myUserCategory;

  void getMyNameAndmyUserId() async {
    myUserId = await FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> myInitUserName =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(myUserId)
            .get();
    myUserName = myInitUserName['userName'];
    myProfilePicture = myInitUserName['profilePicture'];
    myUserCategory = myInitUserName['userCategory'];
  }

  // This function will be called when a search is performed
  void searchMarketPlaceProducts(String searchQuery) async {
    String searchLower = searchQuery.trim().toLowerCase();
    if (searchLower.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('marketPlacePage')
        .where('productDetails.searchIndex',
            arrayContainsAny: [searchLower]).get();

    setState(() {
      searchResults = querySnapshot.docs;
    });
  }

  @override
  void initState() {
    // implement initState
    getMyNameAndmyUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
          // This is the AppBar
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 5.0,
            shadowColor: NeedlincColors.black1,
            iconTheme: const IconThemeData(color: NeedlincColors.blue1),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: const Text(
                      "MARKET PLACE",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Post button section
                    Column(children: [
                      IconButton(
                        icon: Icon(Icons.add),
                        iconSize: 30,
                        color: Color(0XFF007AFF),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MarketPlacePostPage()));
                        },
                      ),
                      Text(
                        "Add post",
                        style: TextStyle(
                          color: Color(0xFF77B8FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                        ),
                      )
                    ]),

                    // Search bar section
                    Container(
                        height: 38,
                        width: screenWidth * 0.64,
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        decoration: BoxDecoration(
                          color: NeedlincColors.black3,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                              hintText: 'Search...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(5)),
                          onChanged: (value) {
                            // Perform search action here
                            searchMarketPlaceProducts(value);
                          },
                        )),

                    // message Icon
                    IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        // Chat messaging feature
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Messages()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            toolbarHeight: 95,
          ),
          body: isSearching
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: max(
                        2,
                        calculateCrossAxisCount(
                            screenWidth, 4, 185)), // Ensure at least 2 columns
                    mainAxisSpacing: 8.0,
                    mainAxisExtent: 211,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    var data =
                        searchResults[index].data() as Map<String, dynamic>;
                    Map<String, dynamic>? userDetails = data['userDetails'];
                    Map<String, dynamic>? productDetails =
                        data['productDetails'];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                      data: data,
                                      userDetails: data['userDetails'],
                                      productDetails: data['productDetails'],
                                    )));
                      },
                      child: Container(
                          width: 185,
                          margin: EdgeInsets.only(left: 7, top: 8, right: 7),
                          decoration: BoxDecoration(
                            color: Color(0xFFEFEEEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: double.maxFinite,
                                height: 141,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "${productDetails!["images"][0]}",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  color: NeedlincColors.black3,
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 7, right: 7),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                            "₦${addCommas(productDetails["price"])}", //Adds comma after every three digits
                                            style: TextStyle(
                                                color: NeedlincColors.blue1,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(height: 1),
                                        Text(
                                            "${selectCharacters(productDetails['name'].toUpperCase(), 35)}",
                                            style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight
                                                    .w600), //First 30 character of  the product name
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1),
                                        SizedBox(height: 1),
                                        Row(children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            height: 24,
                                            child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          NeedlincColors.blue1),
                                                  foregroundColor:
                                                      WidgetStatePropertyAll(
                                                          NeedlincColors.white),
                                                ),
                                                child: Row(children: [
                                                  Text('Buy',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.white)),
                                                  Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      size: 11,
                                                      color: Colors.white)
                                                ]),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatScreen(
                                                        myProfilePicture:
                                                            myProfilePicture,
                                                        otherProfilePicture:
                                                            userDetails![
                                                                'profilePicture'],
                                                        otherUserId:
                                                            userDetails[
                                                                'userId'],
                                                        myUserId: myUserId,
                                                        myUserName: myUserName,
                                                        otherUserName:
                                                            userDetails[
                                                                'userName'],
                                                        nameOfProduct:
                                                            productDetails[
                                                                'name'],
                                                        myPhoneNumber:
                                                            userDetails[
                                                                'phoneNumber'],
                                                        myUserCategory: myUserCategory,
                                                        otherUserCategory:
                                                            userDetails[
                                                                'userCategory'],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ),
                                          Spacer(),
                                          Column(
                                            children: [
                                              Row(children: [
                                                Text(
                                                    "${productDetails['hearts'].length}",
                                                    style: const TextStyle(
                                                        fontSize: 8)),
                                                SizedBox(width: 2),
                                                productDetails['hearts']
                                                        .contains(myUserId)
                                                    ? const Icon(
                                                        Icons.favorite,
                                                        size: 8,
                                                        color:
                                                            NeedlincColors.red,
                                                      )
                                                    : const Icon(
                                                        Icons.favorite_border,
                                                        size: 8,
                                                      ),
                                                SizedBox(width: 10),
                                                Text(
                                                    "${productDetails['comments'].length}",
                                                    style: const TextStyle(
                                                        fontSize: 8)),
                                                SizedBox(width: 2),
                                                SvgPicture.asset(
                                                  'assets/Vector.svg',
                                                  width: 8,
                                                  height: 8,
                                                )
                                              ]),
                                              Text(
                                                "${selectCharacters(userDetails!["address"], 10)}",
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          )
                                        ])
                                      ]))
                            ],
                          )),
                    );
                  },
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: marketPlacePosts.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> postsSnapshot) {
                    if (postsSnapshot.hasError) {
                      return const Text("Something went wrong");
                    }

                    if (postsSnapshot.connectionState ==
                            ConnectionState.active ||
                        postsSnapshot.connectionState == ConnectionState.done) {
                      List<DocumentSnapshot> dataList =
                          postsSnapshot.data!.docs;
                      return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: max(
                                2,
                                calculateCrossAxisCount(screenWidth, 4,
                                    185)), // Ensure at least 2 columns
                            mainAxisSpacing: 8.0,
                            mainAxisExtent: 211,
                          ),
                          itemCount: dataList.length,
                          itemBuilder: (BuildContext context, int index) {
                            // Map<String, dynamic>? userDetails = userDocs[index].data() as Map<String, dynamic>;
                            Map<String, dynamic> data =
                                dataList[index].data() as Map<String, dynamic>;
                            Map<String, dynamic>? userDetails =
                                data['userDetails'];
                            Map<String, dynamic>? productDetails =
                                data['productDetails'];

                            if (productDetails == null) {
                              // Handle the case when productDetails are missing in a document.
                              return const Text("Product details not found");
                            }

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsPage(
                                              data: data,
                                              userDetails: data['userDetails'],
                                              productDetails:
                                                  data['productDetails'],
                                            )));
                              },
                              child: Container(
                                  //width: 185,
                                  margin: EdgeInsets.only(
                                      left: 7, top: 8, right: 7),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEFEEEE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.maxFinite,
                                        height: 141,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              "${productDetails["images"][0]}",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          color: NeedlincColors.black3,
                                          shape: BoxShape.rectangle,
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: 7,
                                          ),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "₦${addCommas(productDetails["price"])}", //Adds comma after every three digits
                                                    style: TextStyle(
                                                        color: NeedlincColors
                                                            .blue1,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                SizedBox(height: 2),
                                                Text(
                                                    "${selectCharacters(productDetails['name'].toUpperCase(), 35)}",
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight: FontWeight
                                                            .w600), //First 30 character of  the product name
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1),
                                                SizedBox(height: 2),
                                                Row(children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    height: 24,
                                                    child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty.all(
                                                                  NeedlincColors
                                                                      .blue1),
                                                          foregroundColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                      .white),
                                                        ),
                                                        child: Row(children: [
                                                          Text('Buy',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                              )),
                                                          Icon(
                                                            Icons
                                                                .shopping_bag_outlined,
                                                            size: 11,
                                                          )
                                                        ]),
                                                        onPressed: () async {
                                                          Map<String, dynamic>?
                                                              userProfileDetails =
                                                              await getUserDataWithUserId(
                                                                  userDetails![
                                                                      'userId']);
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) => ChatScreen(
                                                                  myProfilePicture:
                                                                      myProfilePicture,
                                                                  otherProfilePicture:
                                                                      userDetails![
                                                                          'profilePicture'],
                                                                  otherUserId:
                                                                      userDetails[
                                                                          'userId'],
                                                                  myUserId:
                                                                      myUserId,
                                                                  myUserName:
                                                                      myUserName,
                                                                  otherUserName:
                                                                      userDetails[
                                                                          'userName'],
                                                                  nameOfProduct:
                                                                      productDetails[
                                                                          'name'],
                                                                  myPhoneNumber:
                                                                      userProfileDetails![
                                                                          'phoneNumber'],
                                                                  myUserCategory: myUserCategory,
                                                                  otherUserCategory:
                                                                      userProfileDetails[
                                                                          'userCategory']),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                  Spacer(),
                                                Column(
                                                  children: [
                                                    Row(
                                                        children: [
                                                          Text("${productDetails['hearts'].length}",
                                                              style: const TextStyle(fontSize: 8)
                                                          ),
                                                          SizedBox(width: 2),
                                                          productDetails['hearts']
                                                              .contains(myUserId)
                                                              ? const Icon(
                                                            Icons.favorite,
                                                            size: 8,
                                                            color: NeedlincColors.red,
                                                          )
                                                              : const Icon(
                                                            Icons.favorite_border,
                                                            size: 8,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text("${productDetails['comments'].length}",
                                                              style: const TextStyle(fontSize: 8)
                                                          ),
                                                          SizedBox(width: 2),
                                                          SvgPicture.asset(
                                                            'assets/Vector.svg',
                                                            width: 8,
                                                            height: 8,
                                                          )
                                                        ]
                                                    ),
                                                    Text(
                                                      "${selectCharacters(userDetails!["address"], 10)}",
                                                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w500, color: Colors.grey),
                                                    ),
                                                  ],
                                                )
                                                  /**
                                                  Text(
                                                    "${selectCharacters(userDetails!["address"], 10)}",
                                                    style: TextStyle(
                                                        fontSize: 7,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  )
                                                  */
                                                ])
                                              ]))
                                    ],
                                  )),
                            );
                          });
                    }

                    if (postsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                )),
    );
  }
}
