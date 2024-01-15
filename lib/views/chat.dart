import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../services/chat.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String database = 'mining_laws';
  String modelSelected = 'gpt-4';
  String chatroomId = '1';
  bool loadingResponse = false;
  String? selectedSpecialty;

  ChatService chatService = ChatService();

  List<String> myMessages = [];
  List<String> aiMessages = [
    '¡Hola! Soy AInstein, tu asistente virtual. Estás en el ambiente de Minería ¿En qué puedo ayudarte sobre este tema?'
  ];

  @override
  void initState() {
    super.initState();
    chatService.socket
        .on('initialize_chatroom', (data) => handleInitChatroom(data));
    chatService.socket.on('chat_with_bot', (data) => handleChatWithBot(data));
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshChatView());
  }

  @override
  void dispose() {
    super.dispose();
    chatService.disconnect();
  }

  void handleInitChatroom(data) {
    if (data['error']) {
      print('Message: $data');
      return;
    }
    Navigator.pop(context);
  }

  void handleChatWithBot(data) {
    if (data['error'] == 'Chatbot not initialized') {
      print('Message: $data');
      refreshChatView();
      return;
    }
    if (!data['error'] && data['first']) createAIMessage(data['message']);
    if (!data['error'] && !data['first']) updateAIMessages(data['message']);
  }

  void refreshChatView() async {
    setState(() {
      myMessages = [];
      aiMessages = [
        '¡Hola! Soy AInstein, tu asistente virtual. Estás en el ambiente de Minería ¿En qué puedo ayudarte sobre este tema?'
      ];
    });
    // Show modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: const Text('Cargando modelo'),
            content: SizedBox(
              height: 60,
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.black,
                    size: 60,
                  ))),
            ));
      },
    );
    chatService.initializeChatbot(modelSelected, database);
  }

  void createAIMessage(result) async {
    setState(() {
      aiMessages.add(result.replaceAll('"', ''));
    });
  }
  
  void updateAIMessages(result) async {
    setState(() {
      if (result == 'STREAM_END') {
        loadingResponse = false;
      }
      else {
        aiMessages.last += result.replaceAll('"', '');
      }
    });
  }

  void updateHumanMessages(result) async {
    setState(() {
      loadingResponse = true;
      myMessages.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leyes Mineras'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Column(
          children: [
            const SizedBox(
              height: 130,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 88, 88, 88),
                ),
                child: Row(
                  children: [
                    Text('AInstein',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          color: Color.fromARGB(255, 231, 231, 231),
                        )),
                    SizedBox(width: 10),
                    // Icon(
                    //   FontAwesomeIcons.brain,
                    //   color: Color.fromARGB(255, 231, 231, 231)
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Text('Especialidades',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )),
                  ),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  specialty('Leyes Mineras', 'pickaxe.png', 'mining_laws', context),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  specialty('Leyes Ambientales', 'pickaxe.png', 'environmental_laws',context),
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Text('Más por venir...',
                        style: TextStyle(
                          color: Color.fromARGB(255, 87, 87, 87),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChatMessages(myMessages: myMessages, aiMessages: aiMessages),
              MyCustomForm(
                chatService: chatService,
                updateAIMessages: updateAIMessages,
                updateHumanMessages: updateHumanMessages,
                loadingResponse: loadingResponse,
                database: database,
                chatroomId: chatroomId,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget specialty(String title, String icon, String vectorDb,
      BuildContext context) {
    List<String> chatrooms = ['1', '2', '3', '4'];
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: Image.asset('assets/$icon', height: 25),
          trailing: const Icon(Icons.arrow_drop_down),
          tileColor: selectedSpecialty != title && database == vectorDb
                            ? Theme.of(context).colorScheme.secondary
                            : null,
          onTap: () {
            setState(() {
              if (selectedSpecialty == title) {
                selectedSpecialty = null;
                return;
              }
              selectedSpecialty = title;
            });
          },
        ),
        selectedSpecialty == title
            ? Column(
                children: chatrooms
                    .map(
                      (currentId) => ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Chatroom $currentId',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        tileColor: chatroomId == currentId && database == vectorDb
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                        onTap: () {
                          setState(() {
                            chatroomId = currentId;
                            database = vectorDb;
                          });
                          // Then close the drawer
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList() + [
                      ListTile(
                        title: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.add),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            print('add a chatroom');
                          });
                          // Then close the drawer
                          // Navigator.pop(context);
                        },
                      ),
                    ],
              )
            : const SizedBox()
      ],
    );
  }
}

class MyCustomForm extends StatefulWidget {
  final ChatService chatService;
  final Function updateHumanMessages;
  final Function updateAIMessages;
  final bool loadingResponse;
  final String database;
  final String chatroomId;
  const MyCustomForm(
      {required this.chatService,
      required this.updateAIMessages,
      required this.updateHumanMessages,
      required this.loadingResponse,
      required this.database,
      required this.chatroomId,
      super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String modelSelected = 'gpt-4';

  final TextEditingController _textEditingController = TextEditingController();

  Future _sendMessage() async {
    if (widget.loadingResponse == true || _textEditingController.text.isEmpty) {
      return;
    }
    // Validate returns true if the form is valid, or false otherwise.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      widget.updateHumanMessages(_textEditingController.text);
    });
    String question = _textEditingController.text;
    _textEditingController.clear();
    try {
      widget.chatService.chatWithBot(widget.chatroomId, question, context);
    } catch (e) {
      print("Error: $e");
    }
    // if (!context.mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _textEditingController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextButton(
                      onPressed: _sendMessage,
                      child: widget.loadingResponse
                          ? const SizedBox(
                              width: 20, // ancho del loader
                              height: 20, // altura del loader
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ))
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessages extends StatelessWidget {
  final List<String> myMessages;
  final List<String> aiMessages;

  const ChatMessages(
      {required this.myMessages, required this.aiMessages, super.key});

  @override
  Widget build(BuildContext context) {
    int chatLength = myMessages.length + aiMessages.length;
    chatLength += (chatLength + 1) % 2;
    return Flexible(
      child: ListView.separated(
        // reverse: true,
        padding: const EdgeInsets.all(10.0),
        itemCount: chatLength,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 20,
          color: Colors.black,
        ),
        itemBuilder: (context, index) {
          if (index % 2 != 0 && index ~/ 2 < myMessages.length) {
            return ListTile(
              title: Text(myMessages[index ~/ 2]),
              leading: const SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.blue,
                    ),
                    Text(
                      'Yo',
                      style: TextStyle(
                        color: Colors.blueGrey, // color del texto
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (index % 2 == 0 && index ~/ 2 < aiMessages.length) {
            return ListTile(
                title: Text(aiMessages[index ~/ 2]),
                leading: const SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.brain,
                          color: Color.fromARGB(255, 239, 153, 182)),
                      Text(
                        'AInstein',
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ));
          }
          return ListTile(
              title: SizedBox(
                height: 30,
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: LoadingAnimationWidget.stretchedDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    )),
              ),
              leading: const SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.brain,
                        color: Color.fromARGB(255, 239, 153, 182)),
                    Text(
                      'AInstein',
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
