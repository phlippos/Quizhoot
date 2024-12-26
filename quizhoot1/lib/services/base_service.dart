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
    'user-delete': 'delete/',
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
    'update-set-flashcard': 'set_flashcards/update/<int:flashcard_id>/<int:set_id>/',

    // Quiz routes
    'add-quiz': 'quiz/add/<int:set_id>/',
    'list-quiz': 'quiz/list/<int:set_id>/',

    // Classroom routes
    'classroom-list': 'classrooms/list/',  // To list all classrooms created by the user
    'classroom-add': 'classrooms/add/',    // To create a new classroom
    'classroom-delete': 'classrooms/delete/<int:pk>/',  // To delete a classroom by its ID
    'classroom-update': 'classrooms/update/<int:pk>/',  // To update a classroom by its ID
    'classroom-add-set': 'classrooms/<int:pk>/add-set/',  // To add a set to a classroom
    'classroom-remove-set': 'classrooms/<int:pk>/remove-set/',  // To remove a set from a classroom
    'classroom-add-folder': 'classrooms/<int:pk>/add-folder/',  // To add a folder to a classroom
    'classroom-remove-folder': 'classrooms/<int:pk>/remove-folder/',  // To remove a folder from a classroom
    'classroom-list-sets-folders': 'classrooms/<int:pk>/list-sets-folders/',  // To list all sets and folders in a classroom
    'classroom-user-list': 'classrooms_user/list/',
    'classroom-members-list': 'classrooms_user/members_list/<int:classroom_id>/',
    'classroom-user-add-user': 'classrooms_user/add_user_2_classroom/',
    'classroom-remove-user':'classrooms_user/remove_user_from_classroom/<int:classroom_id>/',

    // Folder routes
    'create-folder': 'folders/create/',
    'list-folders': 'folders/list/',
    'rename-folder': 'folders/<int:pk>/rename/',
    'folder-detail': 'folders/<int:pk>/', // for GET, PUT, DELETE
    'add-set-to-folder': 'folders/<int:pk>/add_set/',
    'remove-set-from-folder': 'folders/<int:pk>/remove_set/<int:set_id>/',
    'list-sets-in-folder': 'folders/<int:pk>/sets/',
        
    'chat-connect': 'ws://your-backend-url/ws/chat',
    'chat-send': 'chat/messages/send',
    'chat-history': 'chat/messages/history',

    'create-notification': 'notifications/create/',
    'list-notifications': 'notifications/<int:classroom_id>/list/',
    'delete-notification': 'notifications/<int:pk>/delete/',
    'list-user-notification': 'notifications/list_user_notification/',
    'remove-user-from-notification': 'notifications/remove_user_from_notification/<int:notification_id>/',
    'all-sets': 'sets/list_all/',

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