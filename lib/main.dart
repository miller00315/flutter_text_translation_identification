import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
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
  late TextEditingController _textEditingController;

  String _result = 'Translated text...';

  bool _isAppReady = false;

  late OnDeviceTranslatorModelManager _modelManager;

  late LanguageIdentifier _languageIdentifier;

  TranslateLanguage? _source;

  TranslateLanguage? _target;

  OnDeviceTranslator? _onDeviceTranslator;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _modelManager = OnDeviceTranslatorModelManager();
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

    setUpModels().then(
      (_) => setState(
        () {
          _isAppReady = true;
          _source;
          _target;
        },
      ),
    );
  }

  @override
  void dispose() async {
    _focusNode.dispose();
    _textEditingController.dispose();
    _languageIdentifier.close();

    super.dispose();
  }

  Future setUpModels() async {
    _source = await checkAndDownloadModel(language: TranslateLanguage.english);

    _target =
        await checkAndDownloadModel(language: TranslateLanguage.portuguese);
  }

  Future<TranslateLanguage?> checkAndDownloadModel(
      {required TranslateLanguage language}) async {
    final bool isModelDownloaded =
        await _modelManager.isModelDownloaded(language.bcpCode);

    if (!isModelDownloaded) {
      await _modelManager.downloadModel(language.bcpCode);
    }

    return language;
  }

  translateText(String text) {
    _focusNode.unfocus();

    if (_source != null && _target != null) {
      _onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: _source!,
        targetLanguage: _target!,
      );

      _onDeviceTranslator
          ?.translateText(text)
          .then((value) => {
                setState(() {
                  _result = value;
                }),
              })
          .whenComplete(
            () => _onDeviceTranslator?.close(),
          );
    }

    _identifyLanguages(text);
  }

  _identifyLanguages(String text) async {
    final String response = await _languageIdentifier.identifyLanguage(text);

    _textEditingController.text += ' ($response)';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            color: Colors.black12,
            child: _isAppReady
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
                              Text(
                                _source?.name ?? 'Unknown',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                height: 48,
                                width: 1,
                                color: Colors.white,
                              ),
                              Text(
                                _target?.name ?? 'Unknown',
                                style: const TextStyle(
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
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.done,
                              controller: _textEditingController,
                              onEditingComplete: () =>
                                  translateText(_textEditingController.text),
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
                            translateText(_textEditingController.text);
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
                              _result,
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
