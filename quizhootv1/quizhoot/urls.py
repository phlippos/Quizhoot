from django.urls import path
from .views import UserViewSet,SetViewSet,UserProfileViewSet
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    
)

urlpatterns = [
    path('users/list', UserViewSet.as_view({"get":"list_user"}),name="user-list"),
    path('users/create', UserViewSet.as_view({"post":"create_user"}),name="user-create"),
    path('update-mindfulness/',UserProfileViewSet.as_view({"post":"set_mindfulness"}),name="set-mindfulness"),
    path('login/',UserViewSet.as_view({"post":"user_login"}),name="user-login"),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('sets/list/', SetViewSet.as_view({'get': 'list_sets'}), name='list_sets'),
    path('sets/add/', SetViewSet.as_view({'post': 'add_set'}), name='add_set'),
    path('sets/delete/<int:ID>/', SetViewSet.as_view({'delete': 'delete_set'}), name='delete_set'),  # Use ID here
    path('sets/update/<int:ID>/', SetViewSet.as_view({'put': 'update_set'}), name='update_set')    # Use ID here
]


"""
Bu yapılandırma, aşağıdaki URL'leri otomatik olarak oluşturur:

GET /items/: Tüm öğeleri listelemek veya yeni bir öğe oluşturmak için.
GET /items/{id}/: Belirli bir öğenin detayını getirmek için.
PUT /items/{id}/: Belirli bir öğeyi tamamen güncellemek için.
PATCH /items/{id}/: Belirli bir öğeyi kısmi olarak güncellemek için.
DELETE /items/{id}/: Belirli bir öğeyi silmek için.
    
"""