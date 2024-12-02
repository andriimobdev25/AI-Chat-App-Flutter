import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:future_builder_ex/future_builder_ex.dart';
import 'package:go_router/go_router.dart';

import '../data/chat_repository.dart';
import '../data/settings.dart';
import '../login_info.dart';
import '../views/settings_drawer.dart';
import 'split_or_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final String _searchText = '';

  late LlmProvider _provider = _createProvider();

  // create a new provider with the given history and the current settings
  LlmProvider _createProvider([List<ChatMessage>? history]) => VertexProvider(
        history: history,
        model: FirebaseVertexAI.instance.generativeModel(
          model: 'gemini-1.5-flash',
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: Schema(
              SchemaType.object,
              properties: {
                'recipes': Schema(
                  SchemaType.array,
                  items: Schema(
                    SchemaType.object,
                    properties: {
                      'text': Schema(SchemaType.string),
                      'recipe': Schema(
                        SchemaType.object,
                        properties: {
                          'title': Schema(SchemaType.string),
                          'description': Schema(SchemaType.string),
                          'ingredients': Schema(
                            SchemaType.array,
                            items: Schema(SchemaType.string),
                          ),
                          'instructions': Schema(
                            SchemaType.array,
                            items: Schema(SchemaType.string),
                          ),
                        },
                      ),
                    },
                  ),
                ),
                'text': Schema(SchemaType.string),
              },
            ),
          ),
          systemInstruction: Content.system(Settings.systemInstruction),
        ),
      );

  final _repositoryFuture = ChatRepository.forCurrentUser;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flutter AI Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout: ${LoginInfo.instance.displayName!}',
              onPressed: () async => LoginInfo.instance.logout(),
            ),
            IconButton(
              onPressed: _onAdd,
              tooltip: 'Add Recipe',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        drawer: Builder(
          builder: (context) => SettingsDrawer(onSave: _onSettingsSave),
        ),
        body: FutureBuilderEx<ChatRepository>(
          future: _repositoryFuture,
          builder: (context, repository) => SplitOrTabs(
            tabs: const [
              Tab(text: 'Chats'),
              Tab(text: 'Chat'),
            ],
            children: [
              Column(
                children: [
                  Expanded(
                    child: ChatListView(
                      searchText: _searchText,
                      repository: repository!,
                    ),
                  ),
                ],
              ),
              LlmChatView(
                provider: _provider,
                responseBuilder: (context, response) => RecipeResponseView(
                  repository: repository,
                  response: response,
                ),
              ),
            ],
          ),
        ),
      );

  void _onAdd() => context.goNamed(
        'edit',
        pathParameters: {'chat': ChatRepository.newChatID},
      );

  void _onSettingsSave() => setState(() {
        // move the history over from the old provider to the new one
        final history = _provider.history.toList();
        _provider = _createProvider(history);
      });
}

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) =>
      ListView.builder(itemBuilder: (context, index) => Text('Chat $index'));
}
