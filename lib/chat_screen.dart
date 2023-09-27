import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //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
  //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
  //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
  late OpenAI openAI;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    openAI = OpenAI.instance.build(
        token: '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',
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 25)),
        enableLog: true);
  }

  Future<void> completeWithSSE() async {
    final request = CompleteText(
        prompt: controller.text, maxTokens: 200, model: TextDavinci3Model());
    CompleteResponse? response = await openAI.onCompletion(request: request);
    if (response != null) {
      print(response.choices.last.text);
      result = response.choices.last.text;
      setState(() {
        result;
      });
    }
  }

  Future<void> chatComplete() async {
    final request = ChatCompleteText(messages: [
      Messages(role: Role.user, content: controller.text)
    ], maxToken: 500, model: GptTurbo0301ChatModel());
    final response = await openAI.onChatCompletion(request: request);
    bool isFirst=true;
    for (var element in response!.choices) {
      ChatMessage msg = ChatMessage(user: openAIUser,
          createdAt: DateTime.now(),
          text: element.message!.content);
      if(isFirst){
        isFirst=false;
      }else{
        messages.removeAt(0);
      }
        messages.insert(0, msg);
      setState(() {
        messages;
      });

      // result=element.message!.content;
      // setState(() {
      //   result;
      // });
    }
  }

  Future<void> _generateImage() async {
    var prompt = controller.text;
    controller.text='';
    final request = GenerateImage(
        prompt, 1, size: ImageSize.size256, responseFormat: Format.url);
    GenImgResponse? response = await openAI.generateImage(request);
    ChatMessage msg=ChatMessage(user: openAIUser, createdAt: DateTime.now(),medias: [ChatMedia(url: response!.data!.last!.url!, fileName: 'image', type: MediaType.image)]);
    messages.insert(0,msg);
    setState(() {
      messages;
    });
  }


  TextEditingController controller = TextEditingController();
  String result = 'result to be show here';
  bool isFirt = true;
  List<ChatMessage> messages = <ChatMessage>[
  ];

  ChatUser userMe = ChatUser(
    id: '1',
    firstName: 'Son',
    lastName: 'Le',
  );

  ChatUser openAIUser = ChatUser(
    id: '2',
    firstName: 'ChatGpt',
    lastName: 'AI',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(child: DashChat(
          messages: messages,
          currentUser: userMe,
          onSend: (m) {},
          readOnly: true,),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: Card
                    (shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)), child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(controller: controller,
                      decoration: const InputDecoration(
                          hintText: 'Type here...', border: InputBorder.none),),
                  ))),
              ElevatedButton(onPressed: () {
                ChatMessage msg = ChatMessage(user: userMe,
                    createdAt: DateTime.now(),
                    text: controller.text);
                messages.insert(0, msg);
                setState(() {
                  messages;
                });
                if(controller.text.toLowerCase().startsWith('generate image')){
                  _generateImage();
                }
                else{
                  chatComplete();
                }

              },
                child: Icon(Icons.send),
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), padding: EdgeInsets.all(12)),),
            ],
          ),
        )
      ],
    );
  }
}
