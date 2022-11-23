import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();

  void SaveData() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();

    // nameController.clear();
    // emailController.clear();
    if (name != "" && email != "") {
      Map<String, dynamic> UserData = {"name": name, "email": email};
      FirebaseFirestore.instance.collection("users").add(UserData);
      print('User Created');
    } else {
      print('Please Enter All Fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeScreen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            SizedBox(height: 20),
            CupertinoButton(
                child: Text('Submit'),
                color: Colors.blue,
                onPressed: () {
                  SaveData();
                }),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.connectionState == ConnectionState.active) {
                  print(snapshot.connectionState);
                  if (snapshot.hasData && snapshot.data != null) {
                    print(snapshot.hasData);
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          print('user: ${userMap["name"]}');
                          print('user: ${userMap["email"]}');
                          // return ListTile(
                          //   title: Text(
                          //     userMap['name'],
                          //     style: TextStyle(
                          //         fontSize: 14, fontWeight: FontWeight.bold),
                          //   ),
                          //   subtitle: Text(
                          //     userMap['email'],
                          //     style: TextStyle(
                          //         fontSize: 14, fontWeight: FontWeight.bold),
                          //   ),
                          // );
                        },
                      ),
                    );
                  } else {
                    return Text('No Data');
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
