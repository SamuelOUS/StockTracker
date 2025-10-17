import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/providers/stock_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_app/constants/custom_colors.dart';
import 'package:my_app/screens/register_page.dart';
import 'package:my_app/screens/lobby.dart';
import 'package:my_app/components/primary_button.dart';
import 'package:my_app/components/custom_text_field.dart';
import 'package:my_app/providers/historical_data_provider.dart';



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => HistoricalDataProvider()), // ✅ AÑADIDO
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const AuthPage(),
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,


        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black, 
          selectionColor: Colors.transparent,
          selectionHandleColor: Colors.black, 
        ),

       
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5F5), 
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIconColor: Colors.black87,
          suffixIconColor: Colors.black87,
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black45),
        ),

      
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.black87),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "¡Bienvenido!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Inicia sesión para continuar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 30),

                CustomTextField(
                  label: "Correo electrónico",
                  placeholder: "Ingresa tu correo",
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator: (value) {
                    return null;
                    if (value == null || value.isEmpty) {
                      return "El correo es obligatorio";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Ingresa un correo válido";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print("Correo: $value");
                  },
                  prefixIcon: const Icon(Icons.email),
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: "Contraseña",
                  placeholder: "Ingresa tu contraseña",
                  isPassword: true,
                  validator: (value) {
                    return null;
                    if (value == null || value.isEmpty) {
                      return "La contraseña es obligatoria";
                    }
                    if (value.length < 6) {
                      return "Debe tener al menos 6 caracteres";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print("Contraseña: $value");
                  },
                  prefixIcon: const Icon(Icons.lock),
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                  text: "Iniciar sesión",
                  onPressed: () async {
              
                    if (true) {
                      final stockProvider =
                          Provider.of<StockProvider>(context, listen: false);
                      await stockProvider.fetchTrending();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LobbyPage(),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  "¿No tienes cuenta?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Regístrate",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
