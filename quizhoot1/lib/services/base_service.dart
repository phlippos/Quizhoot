import 'dart:collection';

abstract class BaseService {
  final String _baseurl = 'http://10.0.2.2:8000/api/';
  final HashMap<String, String> _links;

  BaseService()
      : _links = HashMap<String, String>.from({
    // User routes
    'user-list': 'users/list/',
    'user-create': 'users/create/',
    'user-login': 'login/',
    'user-update': 'update/',

    // JWT Token routes
    'token-obtain-pair': 'api/token/',
    'token-refresh': 'api/token/refresh/',

    // Set routes
    'list-sets': 'sets/list/',
    'add-set': 'sets/add/',
    'delete-set': 'sets/delete/<int:pk>/',
    'update-set': 'sets/update/<int:pk>/',

    // Flashcard routes
    'list-flashcards': 'flashcards/list/',
    'add-flashcard': 'flashcards/add/',
    'delete-flashcard': 'flashcards/delete/<int:pk>/',
    'update-flashcard': 'flashcards/update/<int:pk>/',

    // Set_Flashcard routes
    'list-set-flashcards': 'set_flashcards/list/<int:set_id>/',
    'add-set-flashcard': 'set_flashcards/add/',
    'delete-set-flashcard': 'set_flashcards/delete/<int:flashcard_id>/',
    'update-set-flashcard': 'set_flashcards/update/<int:flashcard_id>/',

    // Quiz routes
    'add-quiz': 'quiz/add/<int:set_id>/',
    'list-quiz': 'quiz/list/<int:set_id>/'
  });



  String? getLink(String key, [Map<String, String>? params]) {
    String? endpoint = _links[key];
    if (endpoint == null) {
      return null;
    }

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        endpoint = endpoint!.replaceAll(paramKey, paramValue);
      });
      return '$_baseurl$endpoint';
    }

    return '$_baseurl${_links[key]}';
  }
}
