import 'package:local_auth/local_auth.dart';


final LocalAuthentication auth = LocalAuthentication();
bool _canCheckBiometrics;
List<BiometricType> _availableBiometrics;
String _authorized = 'Not Authorized';


// ignore: expected_executable, missing_class_body
class fingerPrint(){

  Future<void> _checkBiometrics() async{
    bool canCheckBiometrics;

    try{
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch(e){
      print(e);
    }
    if(!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {

    List<BiometricType> availableBiometrics;

    try{
      availableBiometrics = await auth.getAvailableBiometrics();
    }on PlatformException catch(e){
      print(e);
    }
    if(!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async{

    bool authenticated = false;
    try{
      authenticated = await auth.authenticateWithBiometrics(
      localizedReason: 'Scan your fingerprint to authenticate',
      useErrorDialogs: true,
      stickyAuth: false);
    }on PlatformException catch(e){
      print(e);
    }

    if(!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorizaed' : 'Not Authorized';
    });
  }
}

