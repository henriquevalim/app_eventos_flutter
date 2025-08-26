import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importa a tela de pacotes

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de telas que serão exibidas pela barra de navegação
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Index 0
    Text('Tela de Agenda'), // Index 1
    Text('Tela de Chat'),   // Index 2
    Text('Tela de Perfil'),  // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
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
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey, // Cor para ícones não selecionados
        showUnselectedLabels: true, // Mostra o label dos itens não selecionados
        onTap: _onItemTapped,
      ),
    );
  }
}