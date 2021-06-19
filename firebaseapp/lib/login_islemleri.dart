import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



class LoginIslemleri extends StatefulWidget {
  //const LoginIslemleri({Key key}) : super(key: key);


  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
        _auth
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        print('kullanıcı oturumu kapattı');
      } else {
        if(user.emailVerified) {
          print('kullanıcı oturum açtı mail onaylandı!');
        }else{
          print("Mail onaylanmadı");
        }
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      appBar: AppBar(title: Text("Login İşlemleri"),),
      body: Container(
        child: Center(
          child: Column(
            children: [
              RaisedButton(onPressed: () {
                _mailVeSifreIleKullaniciKaydi();
              },child: Text("Mail ve şifre ile kullanıcı kaydı"),color: Colors.amber,),
              RaisedButton(onPressed: () {
                _mailSifreIleKullaniciGirisYap();
              },child: Text("Mail ve şifre ile kullanıcı girişi"),
                color: Colors.amber,),
              RaisedButton(onPressed: () {
                cikisYap();
              },child: Text("Çıkış Yap"),color: Colors.amber,),
              RaisedButton(onPressed: () {
                cikisYap();
              },child: Text("Şifremi Unuttum"),color: Colors.amber,),
              RaisedButton(onPressed: () {
                _resetPassword();
              },child: Text("Şifre Güncelle"),color: Colors.amber,),
              RaisedButton(onPressed: () {
                _mailGuncelle();
              },child: Text("Mail Güncelle"),color: Colors.amber,),
              RaisedButton(onPressed: () {
                _googleIleGiris();
              },child: Text("Google ile giriş"),color: Colors.amber,),
              RaisedButton(onPressed: () {
                _telNumarasiIleGiris();
              },child: Text("Tel numarası ile giriş"),color: Colors.amber,),
            ],
          ),
        ),
      ),
    );
  }

  void _mailVeSifreIleKullaniciKaydi() async {
    String _mail = "aaa@gmail.com";
    String _password = "password";

    try{
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _mail, password: _password);
      User _yeniUser = _credential.user;
      _yeniUser.sendEmailVerification();
      if(_auth.currentUser != null) {
        debugPrint("Mailinizi onaylayın");
        await _auth.signOut();
        debugPrint("Kullanıcı sitemdem çıktı");
      }
      debugPrint(_yeniUser.toString());
    }catch(e) {
      debugPrint("****************************HATA VAR********************");
      debugPrint("hata:"+e.toString());
    }
  }

  void _mailSifreIleKullaniciGirisYap() async{

    String _mail = "aaa@gmail.com";
    String _password = "password";

    try{
      if(_auth.currentUser == null) {
        User _oturumAcanUser = (await _auth.signInWithEmailAndPassword(
            email: _mail, password: _password))
            .user;
        if(_oturumAcanUser.emailVerified){
          debugPrint("İşlemlerinize devam edebilirsiniz..");
        }else{
          debugPrint("Mailiniziz onaylayıp tekrar giriş yapın");
          _auth.signOut();
        }


      }else{
        debugPrint("Oturum açmış kullanıcı var");
      }
    }catch(e) {
      debugPrint("Hata: "+e.toString());
    }
  }

  void cikisYap() async{

    if(_auth.currentUser != null) {
      await _auth.signOut();
    }else{
      debugPrint("Oturum açık değil");
    }
  }

  void _resetPassword() async{
    String _mail = "aaa@gmail.com";

    try{
      await _auth.sendPasswordResetEmail(email: _mail);
      debugPrint("Resetleme maili gönderildi");
    }catch(e){
  debugPrint("Şİfre resetlenirken hata oluştu : $e");
    }
  }

  void _sifreGuncelle() async{
    try{
      await _auth.currentUser.updatePassword("newPassword");
      debugPrint("Şifreniz güncellendi");
    }catch(e) {
      try{
        String email = 'aaa@gmail.com';
        String password = 'newPassword!';

// Create a credential
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential);
        await _auth.currentUser.updatePassword("newPassword");
      }catch(e){
        debugPrint("Hata çıktı $e");
      }
      debugPrint("Şifre Güncellenirken Bir hata oluştu $e");
    }
  }

  void _mailGuncelle() async{
    try{
      await _auth.currentUser.updateEmail("newmail@gmail.com");
      debugPrint("Mailiniz güncellendi");
    } on FirebaseAuthException catch(e){
      try{
        String email = 'newmail@gmail.com';
        String password = 'newPassword!';

// Create a credential
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential);
        await _auth.currentUser.updateEmail("newmail@gmail.com");
        debugPrint("Mailgüncellendi");
      }catch(e){
        debugPrint("Hata çıktı $e");
      }
      debugPrint("Mail Güncellenirken Bir hata oluştu $e");
    }
  }


  Future<UserCredential> _googleIleGiris() async {
    try{
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    }catch(e){
      debugPrint("Hata $e");
    }
  }

  void _telNumarasiIleGiris() async {

    await _auth.verifyPhoneNumber(
      phoneNumber: '+44 7123 123 456',
      verificationCompleted: (PhoneAuthCredential credential) async{
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) async{
        debugPrint("$e");
        // Update the UI - wait for the user to enter the SMS code

      },
      codeSent: (String verificationId, int resendToken) async{
        debugPrint("kod yollandı");
        try{
          String smsCode = '123456';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await _auth.signInWithCredential(credential);
        }catch(e){
          debugPrint("kod hata: $e");
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("timeouta düştü");
      },
    );

  }




}
