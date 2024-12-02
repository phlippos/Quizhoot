
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db import connection
from rest_framework import status
from .models import User,Set,Flashcard,Set_Flashcard
from .serializers import UserSerializer,SetSerializer,FlashcardSerializer,Set_FlashcardSerializer
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
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
        
        user = User.objects.get(username = username)
        if user and user.password == password:
            token, created = Token.objects.get_or_create(user=user)
            serializer = self.get_serializer(user)
            return Response({'access_token': token.key,'user':serializer.data},status = 200)
        return Response({'error': 'Invalid credentials'}, status=400)
    
    
    
class UserProfileViewSet(viewsets.ModelViewSet):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer
    
    def set_mindfulness(self,request):
        try:
            user = User.objects.get(username = request.user.username)
            mindfulness =  request.data.get("mindfulness")
            user.mindfulness = mindfulness
            
            user.save()
                          
            return Response({"statsus": "success", "message" : "updated"},status = status.HTTP_200_OK)
        
        except User.DoesNotExist:
        # Handle case where user does not exist
            return Response({"status": "error", "message": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Catch any other exceptions
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
        
class SetViewSet(viewsets.ModelViewSet):
    """
    ViewSet for handling CRUD operations for the Set model.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = SetSerializer  

    @action(detail=False, methods=['get'], url_path='list')
    def list_sets(self, request):
        user_id = User.get_user_id(request.user.username)
        if not user_id:
            return Response({"error": "user_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        sets = Set.objects.filter(user_id=user_id)
        serializer = SetSerializer(sets, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'], url_path='add')
    def add_set(self, request):
        user_id = User.get_user_id(request.user.username)
        if not user_id:
            return Response({"error": "user_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = SetSerializer(data={'user_id':user_id,'set_name':request.data['set_name'],'size': request.data.get('size')})
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

# Flashcard ViewSet
class FlashcardViewSet(viewsets.ModelViewSet):
    serializer_class = FlashcardSerializer
    authentication_classes = [TokenAuthentication]
    # permission_classes = [IsAuthenticated]
    queryset = Flashcard.objects.all() 

    @action(detail=False, methods=['post'], url_path='add')
    def add_flashcard(self, request):
        data = request.data
        serializer = self.get_serializer(data={
            'term': data['term'],
            'definition': data['definition'],
            'fav_word': data.get('fav_word', False),
        })
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='list')
    def list_flashcards(self, request):
        flashcards = self.get_queryset() # Assuming flashcards belong to sets
        serializer = self.get_serializer(flashcards, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_flashcard(self, request, pk = None):
        try:
            flashcard = Flashcard.objects.get(pk = pk)
            flashcard.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Flashcard.DoesNotExist:
            return Response({"error": "Flashcard not found"}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['put'], url_path='update')
    def update_flashcard(self, request, pk = None):
        try:
            flashcard = Flashcard.objects.get(pk = pk)
        except Flashcard.DoesNotExist:
            return Response({"error": "Flashcard not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(flashcard, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class Set_FlashcardViewSet(viewsets.ModelViewSet):
    serializer_class = FlashcardSerializer
    authentication_classes = [TokenAuthentication]
    serializer_class = Set_FlashcardSerializer
    queryset = Set_Flashcard.objects.all()
    
    @action(detail=False, methods=['post'], url_path='add')
    def add_set_flashcard(self, request):
        user_id = User.get_user_id(request.user.username)
        print(request.user.username)
        serializer = self.get_serializer(data={
            'set_id' : request.data.get('set_id'),
            'flashcard_id' : request.data.get('flashcard_id'),
            'user_id' : user_id
        })
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


    @action(detail=False, methods=['get'], url_path='list')
    def list_set_flashcards(self, request, set_id = None):        
        # Assume `set_id` is obtained from the request
        req_set_id = set_id  # or request.query_params.get('set_id') for GET requests
        user_id = User.get_user_id(request.user.username)
        print(user_id)
        # Get all Flashcards related to the specific Set
        #flashcards = Flashcard.objects.filter(id = Set_Flashcard.objects.filter(set_id=req_set_id))
        flashcards = Flashcard.objects.raw("""
            SELECT f.*,s.fav_word
            FROM Flashcard f 
            INNER JOIN quizhoot_Set_Flashcard s 
            ON f.id = s.flashcard_id 
            WHERE s.set_id = %s AND s.user_id = %s
            """, [req_set_id,user_id])
        print(len(flashcards))
        serializer = FlashcardSerializer(flashcards, many = True)

        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_set_flashcard(self, request, flashcard_id = None):
        try:
            set_flashcard = Set_Flashcard.objects.get(flashcard_id = flashcard_id)
            set_flashcard.delete()
            return Response(status=status.HTTP_200_OK)
        except Set_Flashcard.DoesNotExist:
            return Response({"error": "Set_Flashcard not found"}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['put'], url_path='update')
    def update_set_flashcard(self, request, flashcard_id = None):
        try:
            set_flashcard = Set_Flashcard.objects.get(flashcard_id = flashcard_id)
        except Set_Flashcard.DoesNotExist:
            return Response({"error": "Set_Flashcard not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(set_flashcard, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)