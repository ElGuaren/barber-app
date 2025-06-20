import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/login_page.dart';
import 'package:flutter_firebase/screens/register_page.dart';
import 'package:flutter_firebase/screens/recuperar_contrasena_page.dart'; // ← Asegúrate de que la ruta sea correcta

/* Importar librerias de firebase */
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/recuperar': (context) => const RecuperarContrasenaPage(), 
      },
    );
  }
}
