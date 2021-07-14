import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FirestoreIslemleri extends StatefulWidget {
  const FirestoreIslemleri({Key key}) : super(key: key);

  @override
  _FirestoreIslemleriState createState() => _FirestoreIslemleriState();
}

class _FirestoreIslemleriState extends State<FirestoreIslemleri> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File _secilenResim;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firestore İşlmeleri"),),
      body: Container(
        child: Center(
          child: Column(
            children: [
              RaisedButton(color: Colors.amber, child: Text("Veri ekle"),
                  onPressed: () {
                    _veriEkle();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Veri güncelle"),
                  onPressed: () {
                    _veriGuncelle();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Transaction Ekle"),
                  onPressed: () {
                    //_transactionEkle();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Veri Sil"),
                  onPressed: () {
                    _veriSil();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Veri Oku"),
                  onPressed: () {
                    _veriOku();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Veri Sorgula"),
                  onPressed: () {
                    _veriSorgula();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Galeriden storageye Resim yükleme"),
                  onPressed: () {
                    _galeridenStorageyeResimYukleme();
                  }),
              RaisedButton(color: Colors.amber, child: Text("Kameradan storageye Resim yükleme"),
                  onPressed: () {
                    _kameradanStorageyeResimYukleme();
                  }),
              Expanded(child: _secilenResim == null ? Text("Resim Yok") : Image.file(_secilenResim)),
            ],
          ),
        ),
      ),
    );
  }

  void _veriEkle() {
    Map<String, dynamic> emreEkle = Map();
    emreEkle["ad"] = "melis";
    emreEkle["lisans1"];
    emreEkle["lisans2"];

    _firestore.collection("users").doc("melis").set(
        emreEkle, SetOptions(merge: true)).then((v) =>
        debugPrint("ekleme başarılı"));

    _firestore.collection("users").doc("selin").set(
        {"ad": "selin", "cinsiyet": "kız","para": 300}).whenComplete(() =>
        debugPrint("selin eklendi"));

    _firestore.doc("users/ayse").set({"ad": "ayse"});
    _firestore.collection("users").add({"ad": "ayse", "yas": "17","para": 900});

    String yeniKullaniciID = _firestore.collection("users").doc().id;
    debugPrint("yenş doc id : $yeniKullaniciID");
    _firestore.doc("users/$yeniKullaniciID").set({"yas": "20"});

  }

  void _veriGuncelle() {

    _firestore.doc("users/melis").update({"ad": "esma", "okul ": "lisans","eklenme": FieldValue.serverTimestamp(),
    "begeniSayisi": FieldValue.increment(10)}).then((value) => debugPrint("güncellendi"));
  }
/*
  void _transactionEkle() {
    final DocumentReference ayseRef = _firestore.doc("users/ayse");
    
    _firestore.runTransaction((Transaction transaction) async  {
      DocumentSnapshot ayseData = await ayseRef.get();


      if(ayseData.exists){
        var ayseninParasi=int.parse(ayseData.data()['para']);
        if(ayseninParasi > 100){

          await transaction.update(ayseRef, {'para': (ayseninParasi - 100)});
          await transaction.update(_firestore.doc("users/selin"),
          {'para': FieldValue.increment(100)});

        }
        else{
          debugPrint("yetersiz bakiye");
        }
      }
      else{
        debugPrint("ayse dükkana geldi");
      }

    });



  }
        */
  void _veriSil() {

    // satır silme
    _firestore.doc("users/melis").delete().then((value) {
      debugPrint("silindi");
    }).catchError((e) => debugPrint("silerken hata oluştu"+e.toString()));

    // sütun silme
    _firestore.doc("users/selin").update({"cinsiyet": FieldValue.delete()}).then((value) {
      debugPrint("cinsiyet silindi");
    }).catchError((e) => debugPrint("silinirken hata çıktı" +e.toString()));

  }

  void _veriOku() async {
    /*
    DocumentSnapshot documentSnapshot = await _firestore.doc("users/selin").get();
    debugPrint("döküman id :"+documentSnapshot.id);
    debugPrint("döküman var mı :"+documentSnapshot.exists.toString());
    debugPrint("döküman string :"+documentSnapshot.toString());
    debugPrint("bekleyen yazma var mı :"+documentSnapshot.metadata.hasPendingWrites.toString());
    debugPrint("cacheden mi geldi :"+documentSnapshot.data().toString());
    debugPrint("cacheden mi geldi :"+documentSnapshot.data()['ad'].toString());
    debugPrint("cacheden mi geldi :"+documentSnapshot.data()['para'].toString());


    documentSnapshot.data().forEach((key, deger) {
      debugPrint("key : $key deger :deger");
    });

     */

    _firestore.collection("users").get().then((querySnapshot) {
      debugPrint("User koleksiyonundaki eleman sayısı: "+querySnapshot.docs.length.toString());

      for(int i=0;i<querySnapshot.docs.length;i++){
        debugPrint(querySnapshot.docs[i].data().toString());
      }

      // anlık değişkenlerin dinlenmesi
      DocumentReference ref = _firestore.collection("users").doc("selin");
      ref.snapshots().listen((degisenVeri) {
        debugPrint("anlık :"+degisenVeri.data().toString());
      });


    });
  }

  void _veriSorgula() async{

    var dokumanlar = await _firestore.collection("users").where("ad",isEqualTo: "selin").get();
    for(var dokuman in dokumanlar.docs) {
      debugPrint(dokuman.data().toString());
    }

    var limitliGetir = await _firestore.collection("users").limit(2).get();
    for(var dokuman in limitliGetir.docs) {
      debugPrint("limitli getirilenler : "+dokuman.data().toString());
    }

    var diziSorgula = await _firestore.collection("users").where("dizi", arrayContains: "game of thrones").get();
    for(var dokuman in diziSorgula.docs){
      debugPrint("Dizi şartı ile getirilenler: "+dokuman.data().toString());
    }

    var stringSorgula = await _firestore.collection("users").orderBy("mail").startAt(["ayse"]).endAt(["ayse" +"\uf8ff"]).get();
    for(var dokuman in stringSorgula.docs){
      debugPrint("String sorgula ile getirilenler: "+dokuman.data().toString());
    }


    _firestore.collection("users").doc("ayse").get().then((docAyse) {
      debugPrint("aysenin verileri: " + docAyse.data().toString());

      _firestore.collection("users").orderBy("begeniSayisi")
          .startAt([docAyse.data()["begeniSayisi"]]).get().then((querySnapshot) {
            if(querySnapshot.docs.length > 0){
              for(var bb in querySnapshot.docs) {
                debugPrint("aysenin begenisinden fazla olan kullanıcılar: "+bb.data().toString());
              }
            }
      });
    });
    


  }

  void _galeridenStorageyeResimYukleme() async{

    var resim1 = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      _secilenResim=File(resim1.path);
    });

    var ref = FirebaseStorage.instance.ref().child("users").child("selin").child("profil.png");
    TaskSnapshot uploadTask = await ref.putFile(_secilenResim);

    if(uploadTask != null) {
      var url = (await ref.getDownloadURL()).toString();
      debugPrint("upload edilen resmin urli: "+url);
    }

  }

  void _kameradanStorageyeResimYukleme() async {
    var resim2 = await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      _secilenResim = File(resim2.path);
    });

    var ref = FirebaseStorage.instance.ref().child("users")
        .child("selin")
        .child("profil.png");
    UploadTask uploadTask = (await ref.putFile(_secilenResim)) as UploadTask;

    if (uploadTask != null) {
      var url = await (await ref.getDownloadURL()).toString();
      debugPrint("upload edilen resmin urli: " + url);
    }
  }


}
