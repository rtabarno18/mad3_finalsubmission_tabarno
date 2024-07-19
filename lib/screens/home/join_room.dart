// Import necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad3_finalsubmission_tabarno/Auth/auth_controller.dart';
import 'package:mad3_finalsubmission_tabarno/screens/home/game_room.dart';

class JoinRoomPage extends StatefulWidget {
  final AuthController authController;

  const JoinRoomPage({super.key, required this.authController});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _gameIdController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _gameIdController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final gameId = _gameIdController.text;
    if (gameId.isEmpty) {
      setState(() {
        _errorMessage = 'Game ID cannot be empty';
      });
    } else {
      try {
        //check if the game ID exists in firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('games')
            .doc(gameId)
            .get();
        if (doc.exists) {
          //navigate to the game room if the game ID exists
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameRoomScreen(
                authController: widget.authController,
                gameId: gameId,
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'No room found with this Game ID';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to join room. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Room'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _gameIdController,
                decoration: InputDecoration(
                  labelText: 'Game ID',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _joinRoom,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                ),
                child: const Text('Join Room'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
