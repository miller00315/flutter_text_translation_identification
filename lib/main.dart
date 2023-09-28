import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();
  String result = 'Translated text...';

  bool isAppReady = false;

  late OnDeviceTranslatorModelManager modelManager;

  TranslateLanguage? source;

  TranslateLanguage? destiny;

  OnDeviceTranslator? onDeviceTranslator;

  @override
  void initState() {
    super.initState();

    modelManager = OnDeviceTranslatorModelManager();

    setUpModels();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  setUpModels() async {
    await checkAndDownloadModel(language: TranslateLanguage.english);

    await checkAndDownloadModel(language: TranslateLanguage.portuguese);

    setState(() {
      isAppReady = true;
    });
  }

  checkAndDownloadModel({required TranslateLanguage language}) async {
    final bool isModelDownloaded =
        await modelManager.isModelDownloaded(language.bcpCode);

    if (!isModelDownloaded) {
      await modelManager.downloadModel(language.bcpCode);
    }
  }

  translateText(
    String text, {
    required TranslateLanguage source,
    required TranslateLanguage target,
  }) async {
    onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );

    onDeviceTranslator?.translateText(text).then((value) => {
          setState(() {
            result = value;
          }),
          onDeviceTranslator?.close(),
        });
  }

  identifyLanguages(String text) async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            color: Colors.black12,
            child: isAppReady
                ? Column(
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 10, right: 10),
                        height: 50,
                        child: Card(
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'English',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                height: 48,
                                width: 1,
                                color: Colors.white,
                              ),
                              const Text(
                                'Portuguese',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 2, right: 2),
                        width: double.infinity,
                        height: 250,
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                hintText: 'Type text here...',
                                filled: true,
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.black),
                              maxLines: 100,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 15, left: 13, right: 13),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(color: Colors.white),
                              backgroundColor: Colors.green),
                          child: const Text('Translate'),
                          onPressed: () {
                            translateText(
                              textEditingController.text,
                              target: TranslateLanguage.portuguese,
                              source: TranslateLanguage.english,
                            );
                          },
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: 15, left: 10, right: 10),
                        width: double.infinity,
                        height: 250,
                        child: Card(
                          color: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              result,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      ),
    );
  }
}
