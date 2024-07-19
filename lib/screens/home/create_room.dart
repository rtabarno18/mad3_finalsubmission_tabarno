// Import necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad3_finalsubmission_tabarno/Auth/auth_controller.dart';
import 'package:mad3_finalsubmission_tabarno/screens/home/game_room.dart';

class CreateRoomPage extends StatefulWidget {
  final AuthController authController;

  const CreateRoomPage({super.key, required this.authController});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _gameIdController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _gameIdController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final gameId = _gameIdController.text;
    if (gameId.isEmpty) {
      setState(() {
        _errorMessage = 'Game ID cannot be empty';
      });
    } else {
      try {
        //storing the game ID in firestore
        await FirebaseFirestore.instance.collection('games').doc(gameId).set({
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': widget.authController.currentUser?.uid,
        });
        //navigate to the game room
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameRoomScreen(
              authController: widget.authController,
              gameId: gameId,
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create room. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Room'),
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
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                ),
                child: const Text('Create Room'),
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
