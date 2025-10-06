// Importa as telas necessárias, já com os nomes em inglês
import 'package:eventos_app/screens/calendar_screen.dart';
import 'package:eventos_app/screens/chat_screen.dart';
import 'package:eventos_app/screens/home_screen.dart';
import 'package:eventos_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';

// Widget principal que controla a navegação com a barra inferior
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variável que armazena o índice da aba selecionada
  int _selectedIndex = 0;

  // Lista de telas que serão exibidas. A ordem aqui importa!
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    // CORREÇÃO: O erro estava aqui. O nome da classe foi atualizado para CalendarScreen.
    CalendarScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  // Função chamada quando uma aba é tocada
  void _onItemTapped(int index) {
    // Atualiza o estado para reconstruir a tela com o novo índice
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a tela correspondente ao índice selecionado
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo, // Cor do ícone ativo
        unselectedItemColor: Colors.grey,   // Cor dos ícones inativos
        onTap: _onItemTapped,             // Função a ser chamada ao tocar
        showUnselectedLabels: true,       // Garante que todos os rótulos apareçam
      ),
    );
  }
}

