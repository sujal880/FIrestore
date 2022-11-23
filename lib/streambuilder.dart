import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class stream extends StatefulWidget {
  const stream({Key? key}) : super(key: key);
  @override
  State<stream> createState() => _StreamState();
}

class _StreamState extends State<stream> {
  var nameController=TextEditingController();
  var emailController=TextEditingController();
  var ageController=TextEditingController();
  File? profilepic;

  void SaveData()async{
    String name=nameController.text.trim();
    String email=emailController.text.trim();
    String ageString=ageController.text.trim();

    nameController.clear();
    emailController.clear();
    ageController.clear();

    int age=int.parse(ageString);

    if(name!="" && email!="" && profilepic!=null){
      UploadTask uploadTask= FirebaseStorage.instance.ref().child("profilepictures").child(Uuid().v1()).putFile(profilepic!);
      TaskSnapshot taskSnapshot= await uploadTask;
      String downloadUrl=await taskSnapshot.ref.getDownloadURL();
      Map<String,dynamic> UserData={"name":name,"email":email,"age":age,"profilepic":downloadUrl};
      FirebaseFirestore.instance.collection("users").add(UserData);
      print('User Created');
    }else{
      print('Please Enter All Fields');
    }
    setState(() {
      profilepic=null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stream Builder'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CupertinoButton(onPressed: ()async{
              XFile? selectedImage=await ImagePicker().pickImage(source: ImageSource.gallery);
              if(selectedImage!=null){
                File convertedFile=File(selectedImage.path);
                setState(() {
                  profilepic=convertedFile;
                });
                print("Image Selected");
              }
              else{
                print('No Image Selected');
              }
            },
              child: CircleAvatar(
                backgroundImage: (profilepic!=null)?FileImage(profilepic!):null,
                backgroundColor: Colors.grey,
                radius: 40,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Age',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
              ),
            ),
            SizedBox(height: 20),
            CupertinoButton(child: Text('Submit'),color: Colors.blue, onPressed: (){
              SaveData();
            }),
            SizedBox(height: 30),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot>snapshot){
                  if(!snapshot.hasData){
                    return Center(
                      child:CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                    Map<String,dynamic> userMap=snapshot.data!.docs[index].data() as Map<String,dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userMap['profilepic']),
                      ),
                      title: Text(userMap['name']+"(${userMap['age']})"),
                      subtitle: Text(userMap['email']),
                      trailing: IconButton(onPressed: (){
                        FirebaseFirestore.instance.collection("users").doc('FqME3uGTT49M5bgVn7H7').delete();
                        print('Deleted User');
                      }, icon: Icon(Icons.delete)),
                    );
                    },
                  );
                  // return ListView(
                  //   children: [
                  //     snapshot.data.docs.map((document){
                  //       return Center(
                  //         child: Container(
                  //           width: 50,
                  //           height: 40,
                  //           child: Text("Title"+document['title']),
                  //         ),
                  //       );
                  //     }).toList()
                  //   ],
                  // );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
