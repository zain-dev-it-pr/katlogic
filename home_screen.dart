import 'package:flutter/material.dart';
import 'package:katlogic/screen/animated_background.dart';
import '../services/gemini_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katlogic/neon_chat_bubble.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  // ================= VOICE =================
  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;

  bool _voiceEnabled = false; // 🔥 OFF by default
  bool _isListening = false;

  // ================= CONTROLLERS =================
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ================= MIC ANIMATION =================
  late AnimationController _micController;
  late Animation<double> _micGlowAnimation;

  // ================= CHAT SESSIONS =================
  Map<String, List<Map<String, dynamic>>> chatSessions = {};
  String currentChatId = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _initMicAnimation();
    _createNewChat();
  }

  // ================= TTS =================
  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
  }

  // ================= MIC ANIMATION =================
  void _initMicAnimation() {
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _micGlowAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _tts.stop();
    _micController.dispose();
    super.dispose();
  }

  // ================= NEW CHAT =================
  void _createNewChat() {
    String chatId = DateTime.now().millisecondsSinceEpoch.toString();

    chatSessions[chatId] = [
      {
        'text': 'Assalamu Alaikum 😎\nHow can I help you?',
        'isUser': false,
      }
    ];

    setState(() {
      currentChatId = chatId;
    });
  }

  List<Map<String, dynamic>> get currentMessages =>
      chatSessions[currentChatId]!;

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 10),

              // TOP BAR
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "KATLOGIC",
                    style: GoogleFonts.cinzel(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 10),

              // CHAT LIST
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: currentMessages.length,
                  itemBuilder: (context, index) {
                    final msg = currentMessages[index];
                    return NeonChatBubble(
                      message: msg['text'],
                      isUser: msg['isUser'],
                    );
                  },
                ),
              ),

              if (_isListening)
                const LinearProgressIndicator(
                  backgroundColor: Colors.black,
                  color: Colors.cyanAccent,
                  minHeight: 3,
                ),

              _chatInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DRAWER =================
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF090A1A), // near black blue
              Color(0xFF1B1F3B), // deep space indigo
              Color(0xFF090A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 40),

              /// 🔵 NEON TITLE
              Text(
                "CONVERSATIONS",
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  letterSpacing: 2,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(
                      color: Colors.cyanAccent,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// ⚡ NEON NEW CHAT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00E5FF),
                        Color(0xFF00B0FF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _createNewChat();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        "NEW CHAT",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// 💬 CHAT LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: chatSessions.keys.map((chatId) {
                    final bool isActive = currentChatId == chatId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child:AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          // 🌌 Glass transparent background
                          color: isActive
                              ? Colors.cyanAccent.withOpacity(0.08)
                              : Colors.white.withOpacity(0.05),

                          // 💡 Neon Border
                          border: Border.all(
                            color: isActive
                                ? Colors.cyanAccent
                                : Colors.white24,
                            width: 1.5,
                          ),

                          // ✨ Neon Glow Effect
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            "Chat ${chatId.substring(chatId.length - 4)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive
                                  ? Colors.cyanAccent
                                  : Colors.white70,
                              fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,

                              // ✨ Neon Text Glow
                              shadows: isActive
                                  ? [
                                Shadow(
                                  color: Colors.cyanAccent.withOpacity(0.9),
                                  blurRadius: 12,
                                ),
                                Shadow(
                                  color: Colors.cyanAccent.withOpacity(0.6),
                                  blurRadius: 25,
                                ),
                              ]
                                  : [],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              currentChatId = chatId;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT BAR =================
  Widget _chatInputBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900.withOpacity(0.8),
              Colors.indigo.shade900.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.8),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [

            const SizedBox(width: 12),

            /// 🎤 MIC
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: _isListening
                      ? [
                    BoxShadow(
                      color: Colors.cyanAccent,
                      blurRadius: 25,
                      spreadRadius: 4,
                    )
                  ]
                      : [],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.cyanAccent,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 💬 TEXT FIELD
            Expanded(
              child: TextField(
                controller: _chatController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: "Ask KATLOGIC...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),

            /// 🚀 SEND BUTTON
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.cyanAccent,
                ),
              ),
            ),

            const SizedBox(width: 8),

            /// 🔊 VOICE TOGGLE
            GestureDetector(
              onTap: () async {
                setState(() {
                  _voiceEnabled = !_voiceEnabled;
                });

                if (!_voiceEnabled) {
                  await _tts.stop();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _voiceEnabled
                      ? const LinearGradient(
                    colors: [
                      Color(0xFF00E5FF),
                      Color(0xFF00B0FF),
                    ],
                  )
                      : const LinearGradient(
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF000000),
                    ],
                  ),
                  boxShadow: _voiceEnabled
                      ? [
                    // Outer Neon Glow
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.9),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                    // Soft Inner Glow
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 1,
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Icon(
                  _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                  color: _voiceEnabled ? Colors.black : Colors.white70,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
  // ================= SEND =================
  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      currentMessages.add({'text': text, 'isUser': true});
    });

    _chatController.clear();
    _scrollToBottom();

    try {
      final aiReply = await GeminiService.sendMessage(text);

      setState(() {
        currentMessages.add({'text': aiReply, 'isUser': false});
      });

      _scrollToBottom();
      _speak(aiReply);

    } catch (e) {
      setState(() {
        currentMessages.add({'text': "Error occurred.", 'isUser': false});
      });
    }
  }

  // ================= SPEAK =================
  Future<void> _speak(String text) async {
    if (!_voiceEnabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  // ================= SCROLL =================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================= LISTEN =================
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == "done") _stopListening();
        },
        onError: (_) => _stopListening(),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _micController.repeat(reverse: true);
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _chatController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
    _micController.stop();
  }
}
