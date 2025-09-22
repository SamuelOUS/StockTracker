// lib/screens/lobby.dart
import 'package:flutter/material.dart';
import 'package:my_app/constants/custom_colors.dart';
import 'package:provider/provider.dart';
import 'package:my_app/components/primary_button.dart';
import 'package:my_app/screens/user_form_page.dart';
import 'package:my_app/screens/user_page.dart';
import 'package:my_app/screens/user_search_page.dart';
import 'package:my_app/screens/user_delete_page.dart';
import 'package:my_app/screens/user_update_page.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:my_app/models/user_model.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  void _openUserUpdate(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserUpdatePage(user: user),
      ),
    );
  }

  void _openUserSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserSearchPage(),
      ),
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst); // vuelve a la primera página
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          SizedBox.expand(
            child: Image.asset(
              'assets/images/image.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Contenido principal
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.03,
                ),
                padding: EdgeInsets.all(screenWidth * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '¡Bienvenido a la práctica de desarrollo móvil!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Selecciona una de las opciones de abajo',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    PrimaryButton(
                      text: 'Ver usuarios',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserPage()),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    PrimaryButton(
                      text: 'Buscar usuarios',
                      onPressed: () => _openUserSearch(context),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    PrimaryButton(
                      text: 'Crear usuario',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserFormPage()),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    PrimaryButton(
                      text: 'Eliminar usuario',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserDeletePage()),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    PrimaryButton(
                      text: 'Actualizar usuario',
                      onPressed: () {
                        if (provider.users.isEmpty) return;
                        _openUserUpdate(context, provider.users[0]);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    if (provider.isLoading)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),

          // Botón de salida responsive en la esquina inferior derecha
          Positioned(
            bottom: screenHeight * 0.02,
            right: screenWidth * 0.03,
            child: SizedBox(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              child: FloatingActionButton(
                onPressed: () => _goToLogin(context),
                backgroundColor: CustomColors.primary,
                child: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: screenWidth * 0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
