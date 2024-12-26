from django.urls import path
from .views import UserViewSet,SetViewSet,UserProfileViewSet, FlashcardViewSet, Set_FlashcardViewSet,QuizViewSet,ClassroomViewSet,ClassroomUserViewSet,FolderViewSet,NotificationViewSet,MessageViewSet
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    
)

urlpatterns = [
    # User routes
    path('users/list/', UserViewSet.as_view({"get": "list_user"}), name="user-list"),
    path('users/create/', UserViewSet.as_view({"post": "create_user"}), name="user-create"),
    path('login/', UserViewSet.as_view({"post": "user_login"}), name="user-login"),
    path('update/', UserProfileViewSet.as_view({"put": "update_user"}), name="update-user"),
    path('delete/', UserProfileViewSet.as_view({"delete": "delete_user"}), name="delete-user"),
    # JWT Token routes
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Set routes
    path('sets/list/', SetViewSet.as_view({'get': 'list_sets'}), name='list_sets'),
    path('sets/add/', SetViewSet.as_view({'post': 'add_set'}), name='add_set'),
    path('sets/delete/<int:pk>/', SetViewSet.as_view({'delete': 'delete_set'}), name='delete_set'),
    path('sets/update/<int:pk>/', SetViewSet.as_view({'put': 'update_set'}), name='update_set'),

    # Flashcard routes
    path('flashcards/list/', FlashcardViewSet.as_view({'get': 'list_flashcards'}), name='list_flashcards'),
    path('flashcards/add/', FlashcardViewSet.as_view({'post': 'add_flashcard'}), name='add_flashcard'),
    path('flashcards/delete/<int:pk>/', FlashcardViewSet.as_view({'delete': 'delete_flashcard'}), name='delete_flashcard'),
    path('flashcards/update/<int:pk>/', FlashcardViewSet.as_view({'put': 'update_flashcard'}), name='update_flashcard'),

    # Set_Flashcard routes
    path('set_flashcards/list/<int:set_id>/', Set_FlashcardViewSet.as_view({'get': 'list_set_flashcards'}), name='list_set_flashcards'),
    path('set_flashcards/add/', Set_FlashcardViewSet.as_view({'post': 'add_set_flashcard'}), name='add_set_flashcard'),
    path('set_flashcards/delete/<int:flashcard_id>/', Set_FlashcardViewSet.as_view({'delete': 'delete_set_flashcard'}), name='delete_set_flashcard'),
    path('set_flashcards/update/<int:flashcard_id>/<int:set_id>/', Set_FlashcardViewSet.as_view({'put': 'update_set_flashcard'}), name='update_set_flashcard'),
    
    #Quiz
    path('quiz/add/<int:set_id>/',QuizViewSet.as_view({'post': 'add_quiz'}),name='add_quiz'),
    path('quiz/list/<int:set_id>/',QuizViewSet.as_view({'get': 'list_quiz'}),name='list_quiz'),
    
    
    # Classroom routes
    path('classrooms_user/list/', ClassroomUserViewSet.as_view({'get': 'list_users_classrooms'}), name='list_users_classrooms'),
    path('classrooms_user/members_list/<int:classroom_id>/',ClassroomUserViewSet.as_view({'get':'list_members_of_classrooms'}),name='list_members_of_classrooms'),
    path('classrooms_user/add_user_2_classroom/',ClassroomUserViewSet.as_view({'post':'add_user_2_classroom'}), name='add_user_2_classroom'),
    path('classrooms_user/remove_user_from_classroom/<int:classroom_id>/',ClassroomUserViewSet.as_view({'delete':'delete_user_from_classroom'}), name='delete_user_from_classroom'),
    
    path('classrooms/list/',ClassroomViewSet.as_view({'get': 'list_classrooms'}),name='list_classrooms'),
    path('classrooms/add/', ClassroomViewSet.as_view({'post': 'add_classroom'}), name='add_classroom'),
    path('classrooms/delete/<int:pk>/', ClassroomViewSet.as_view({'delete': 'delete_classroom'}), name='delete_classroom'),
    path('classrooms/update/<int:pk>/', ClassroomViewSet.as_view({'put': 'update_classroom'}), name='update_classroom'),
    path('classrooms/<int:pk>/add-set/', ClassroomViewSet.as_view({'post': 'add_set_to_classroom'}), name='add_set_to_classroom'),
    path('classrooms/<int:pk>/remove-set/', ClassroomViewSet.as_view({'delete': 'remove_set_from_classroom'}), name='remove_set_from_classroom'),
    path('classrooms/<int:pk>/add-folder/', ClassroomViewSet.as_view({'post': 'add_folder_to_classroom'}), name='add_folder_to_classroom'),
    path('classrooms/<int:pk>/remove-folder/', ClassroomViewSet.as_view({'delete': 'remove_folder_from_classroom'}), name='remove_folder_from_classroom'),
    path('classrooms/<int:pk>/list-sets-folders/', ClassroomViewSet.as_view({'get': 'list_sets_and_folders'}), name='list_sets_and_folders'),
    
    # Folder routes
    path('folders/create/', FolderViewSet.as_view({'post': 'create_folder'}), name='create_folder'),
    path('folders/list/', FolderViewSet.as_view({'get': 'list_folders'}), name='list_folders'),
    path('folders/<int:pk>/rename/', FolderViewSet.as_view({'put': 'rename_folder'}), name='rename_folder'),
    path('folders/<int:pk>/', FolderViewSet.as_view({'get': 'retrieve','delete': 'destroy','put': 'update'}), name='folder_detail'),
    path('folders/<int:pk>/add_set/', FolderViewSet.as_view({'post': 'add_set_to_folder'}), name='add_set_to_folder'),
    path('folders/<int:pk>/remove_set/<int:set_id>/', FolderViewSet.as_view({'delete': 'remove_set_from_folder'}), name='remove_set_from_folder'),
    path('folders/<int:pk>/sets/', FolderViewSet.as_view({'get': 'list_sets_in_folder'}), name='list_sets_in_folder'),

    # Message routes
    path('messages/list/', MessageViewSet.as_view({'get': 'list_messages'}), name='list_messages'),
    path('messages/create/', MessageViewSet.as_view({'post': 'create_message'}), name='create_message'),
    
    
    path('notifications/<int:classroom_id>/list/',NotificationViewSet.as_view({'get':'list_notifications_by_classroom'}),name='list_notification'),
    path('notifications/create/',NotificationViewSet.as_view({'post':'create_notification'}),name='create_notification'),
    path('notifications/<int:pk>/delete/',NotificationViewSet.as_view({'delete':'delete_notification'}),name='delete_notification'),
    path('notifications/remove_user_from_notification/<int:notification_id>/',NotificationViewSet.as_view({'delete':'remove_user_from_notification'}),name='remove_user_from_notification'),
    path('notifications/list_user_notification/',NotificationViewSet.as_view({'get':'list_user_notifications'}),name='list_user_notifications'),
]

"""
Bu yapılandırma, aşağıdaki URL'leri otomatik olarak oluşturur:

GET /items/: Tüm öğeleri listelemek veya yeni bir öğe oluşturmak için.
GET /items/{id}/: Belirli bir öğenin detayını getirmek için.
PUT /items/{id}/: Belirli bir öğeyi tamamen güncellemek için.
PATCH /items/{id}/: Belirli bir öğeyi kısmi olarak güncellemek için.
DELETE /items/{id}/: Belirli bir öğeyi silmek için.
    
"""