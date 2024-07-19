import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mad3_finalsubmission_tabarno/Auth/auth_controller.dart';
import 'package:mad3_finalsubmission_tabarno/screens/chat_screen.dart';

class GameRoomScreen extends StatelessWidget {
  final AuthController authController;
  final String gameId;

  const GameRoomScreen({
    super.key,
    required this.authController,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TicTacToeGame(
              authController: authController,
              gameId: gameId,
            ), // Pass gameId and authController to TicTacToeGame
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final AuthController authController;
  final String gameId;

  const TicTacToeGame(
      {super.key, required this.authController, required this.gameId});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = ['', '', '', '', '', '', '', '', ''];
  String _currentPlayer = 'X';
  bool _gameOver = false;
  String _winner = '';
  int _xWins = 0;
  int _oWins = 0;
  String? _userSymbol;
  bool _isWaitingForOpponent = true;

  @override
  void initState() {
    super.initState();
    _assignUserSymbol();
    _subscribeToGameUpdates();
  }

  void _assignUserSymbol() async {
    try {
      DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .get();
      if (gameSnapshot.exists) {
        Map<String, dynamic> gameData =
            gameSnapshot.data() as Map<String, dynamic>;
        if (gameData['playerX'] == null) {
          setState(() {
            _userSymbol = 'X';
            _isWaitingForOpponent = gameData['playerO'] == null;
          });
          FirebaseFirestore.instance
              .collection('games')
              .doc(widget.gameId)
              .update({
            'playerX': widget.authController.currentUser?.uid,
          });
        } else if (gameData['playerO'] == null) {
          setState(() {
            _userSymbol = 'O';
            _isWaitingForOpponent = gameData['playerX'] == null;
          });
          FirebaseFirestore.instance
              .collection('games')
              .doc(widget.gameId)
              .update({
            'playerO': widget.authController.currentUser?.uid,
          });
        }
      }
    } catch (e) {
      print('Error assigning user symbol: $e');
    }
  }

  void _subscribeToGameUpdates() {
    try {
      FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .snapshots()
          .listen((document) {
        if (document.exists) {
          setState(() {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            _board = List<String>.from(data['board']);
            _currentPlayer = data['currentPlayer'];
            _gameOver = data['gameOver'];
            _winner = data['winner'];
            _xWins = data['xWins'];
            _oWins = data['oWins'];
            _isWaitingForOpponent =
                (data['playerX'] == null || data['playerO'] == null);
          });
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      print('Error subscribing to game updates: $e');
    }
  }

  void _updateGame() async {
    try {
      await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .update({
        'board': _board,
        'currentPlayer': _currentPlayer,
        'gameOver': _gameOver,
        'winner': _winner,
        'xWins': _xWins,
        'oWins': _oWins,
      });
    } catch (e) {
      print('Error updating game: $e');
    }
  }

  void _resetGame() {
    setState(() {
      _board = ['', '', '', '', '', '', '', '', ''];
      _currentPlayer = 'X';
      _gameOver = false;
      _winner = '';
      _xWins = 0;
      _oWins = 0;
    });
    _updateGame();
  }

  void _playAgain() {
    setState(() {
      _board = ['', '', '', '', '', '', '', '', ''];
      _currentPlayer = 'X';
      _gameOver = false;
      _winner = '';
    });
    _updateGame();
  }

  void _handleTap(int index) {
    if (_board[index] == '' && !_gameOver && _currentPlayer == _userSymbol) {
      setState(() {
        _board[index] = _currentPlayer;
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        _checkWinner();
      });
      _updateGame();
    }
  }

  void _checkWinner() {
    const List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombinations) {
      if (_board[combination[0]] != '' &&
          _board[combination[0]] == _board[combination[1]] &&
          _board[combination[1]] == _board[combination[2]]) {
        setState(() {
          _gameOver = true;
          _winner = _board[combination[0]];
          if (_winner == 'X') {
            _xWins++;
          } else if (_winner == 'O') {
            _oWins++;
          }
        });
        _updateGame();
        return;
      }
    }

    if (!_board.contains('')) {
      setState(() {
        _gameOver = true;
      });
      _updateGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isWaitingForOpponent
              ? 'Waiting for opponent...'
              : _gameOver
                  ? _winner.isNotEmpty
                      ? 'Winner: $_winner'
                      : 'It\'s a Draw!'
                  : 'Current Player: $_currentPlayer',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 10),
        Text(
          'Player X Wins: $_xWins',
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          'Player O Wins: $_oWins',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _playAgain,
              child: const Text('Play Again'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: const Text('Reset Game'),
            ),
          ],
        ),
      ],
    );
  }
}
