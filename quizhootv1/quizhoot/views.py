
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db import connection
from rest_framework import status
from .models import User,Set
from .serializers import UserSerializer,SetSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.authentication import TokenAuthentication


"""
Django'da views.py dosyası, gelen HTTP isteklerini işleyen ve bir yanıt döndüren işlevlerin (view) bulunduğu yerdir.
View fonksiyonları, kullanıcı tarafından yapılan istekleri (GET, POST, vb.) alır,
veritabanı sorguları yapar, şablonlar (templates) kullanarak HTML yanıtları oluşturur ve bu yanıtları kullanıcılara gönderir.

"""
# Create your views here.

"""
    Django REST Framework (DRF) içinde viewsets.ModelViewSet kullanarak bir API oluşturmak,
    CRUD (Create, Read, Update, Delete) işlemlerini çok hızlı ve kolay bir şekilde gerçekleştirmemizi sağlar.
    ModelViewSet, DRF'in sağladığı en güçlü ve en sık kullanılan view setlerinden biridir.
"""
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()  #queryset, viewset'in hangi verileri kullanacağını belirleyen Django QuerySet nesnesidir. queryset, veritabanından çekilecek olan verileri tanımlar.
    """
    QuerySet Özellikleri:
        Item.objects.all(): Tüm Item nesnelerini seçer.
        Item.objects.filter(active=True): Belirli bir koşula göre filtrelenmiş Item nesnelerini seçer.
        Item.objects.order_by('-created_at'): created_at alanına göre sıralanmış Item nesnelerini seçer.
    """
    serializer_class = UserSerializer #serializer_class, bu viewset'in hangi serializer sınıfını kullanacağını belirler. Serializer, veritabanı modellerinin nasıl JSON veya başka formatlara dönüştürüleceğini ve tersini tanımlar.
    authentication_classes = [TokenAuthentication]
   #filter_backends Hangi filtreleme arka uçlarının kullanılacağını belirler. Bu, queryset'i belirli kriterlere göre filtrelemeyi sağlar.
   # filter_backends = [filters.SearchFilter]
   #search_fields = ['name', 'description']Burada, SearchFilter kullanılarak name ve description alanlarına göre arama yapılabilmesi sağlanır
    
    def create_user(self,request):
        
        serializer =  self.get_serializer(data = request.data)
        if serializer.is_valid():
            user = serializer.save() ##database e kaydet userı
            return Response(serializer.data, status = status.HTTP_201_CREATED)
        return Response(serializer.data, status = status.HTTP_400_BAD_REQUEST)
    
    def list_user(self,request):
        users = self.get_queryset()
        serializer = self.get_serializer(users,many = True)
        return Response(serializer.data)
    
    def user_login(self,request):
        username = request.data.get("username")
        password = request.data.get("password")
        
        if not username or not password : 
            return Response({"error":"username or password cannot be null"},status = status.HTTP_400_BAD_REQUEST)
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT id,password FROM user WHERE username = %s",[username])
            row = cursor.fetchone()
        user_id, password_ = row
        
        if  password == password_:
            user = User.objects.get(id = user_id)
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_200_OK)
        else : 
            return Response({"error" : "password is invalid" },status= status.HTTP_401_UNAUTHORIZED)
    
        
class SetViewSet(viewsets.ModelViewSet):
    """
    ViewSet for handling CRUD operations for the Set model.
    """
    serializer_class = SetSerializer
    @action(detail=False, methods=['get'], url_path='list')
    def list_sets(self, request):
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response({"error": "user_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        sets = Set.objects.filter(user_id=user_id)
        serializer = SetSerializer(sets, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'], url_path='add')
    def add_set(self, request):
        user_id = request.data.get('user_id')
        if not user_id:
            return Response({"error": "user_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = SetSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_set(self, request, ID=None):
        try:
            set_instance = Set.objects.get(ID=ID)  # Use ID instead of pk
            set_instance.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Set.DoesNotExist:
            return Response({"error": "Set not found"}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['put'], url_path='update')
    def update_set(self, request, ID=None):
        try:
            set_instance = Set.objects.get(ID=ID)  # Use ID instead of pk
        except Set.DoesNotExist:
            return Response({"error": "Set not found"}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = SetSerializer(set_instance, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

       