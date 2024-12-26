
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db import connection
from rest_framework import status
from .models import User,Set,Flashcard,Set_Flashcard,Quiz,Quiz_User_Set,Classroom,classroom_user,Folder,Notification,Message
from .serializers import UserSerializer,SetSerializer,FlashcardSerializer,Set_FlashcardSerializer,QuizSerializer,Quiz_User_SetSerializer,Classroom_Serializer,Classroom_User_Serializer,FolderSerializer,NotificationSerializer,MessageSerializer
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
    
    @action(detail=True, methods=['put'], url_path='update')
    def update_user(self, request):
        try:
            user = User.objects.get(username = request.user.username)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete_user(self, request):
        user_id = User.get_user_id(request.user.username)
        if not user_id:
            return Response({"error": "user_id cannot be null"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(id=user_id)
            user.delete()  # Delete the user
            return Response({"message": "User deleted successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
    
        
class SetViewSet(viewsets.ModelViewSet):
    """
    ViewSet for handling CRUD operations for the Set model.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = SetSerializer  
    queryset = Set.objects.all() 
    @action(detail=False, methods=['get'], url_path='list')
    def list_sets(self, request):
        print("username ",request.user.username)
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
    def delete_set(self, request, pk=None):
        try:
            set_instance = Set.objects.get(pk=pk)  # Use ID instead of pk
            set_instance.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Set.DoesNotExist:
            return Response({"error": "Set not found"}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['put'], url_path='update')
    def update_set(self, request, pk=None):
        try:
            set_instance = Set.objects.get(pk=pk)  # Use ID instead of pk
        except Set.DoesNotExist:
            return Response({"error": "Set not found"}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = SetSerializer(set_instance, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'], url_path='list-all')
    def all_sets(self,request):
        user_id = User.get_user_id(request.user.username)
        if not user_id:
            return Response({"error": "user_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        sets = Set.objects.exclude(user_id=user_id)
        serializer = SetSerializer(sets, many=True)
        print(serializer)
        return Response(serializer.data, status=status.HTTP_200_OK)

# Flashcard ViewSet
class FlashcardViewSet(viewsets.ModelViewSet):
    serializer_class = FlashcardSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
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
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = Set_FlashcardSerializer
    queryset = Set_Flashcard.objects.all()
    
    @action(detail=False, methods=['post'], url_path='add')
    def add_set_flashcard(self, request):
        user_id = User.get_user_id(request.user.username)
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
            WHERE s.set_id = %s 
            """, [req_set_id])
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
    def update_set_flashcard(self, request, flashcard_id = None, set_id = None):
        user_id = User.get_user_id(request.user.username)
        try:
            set_flashcard = Set_Flashcard.objects.get(flashcard_id = flashcard_id, user_id=user_id, set_id = set_id)
        except Set_Flashcard.DoesNotExist:
            return Response({"error": "Set_Flashcard not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(set_flashcard, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class QuizUserSetService:
    @staticmethod
    def add_quiz_user_set(set_id, user_id, quiz_id):
        data = {
            'set_id': set_id,
            'user_id': user_id,
            'quiz_id': quiz_id
        }
        serializer = Quiz_User_SetSerializer(data=data)
        
        if serializer.is_valid():
            serializer.save()
            return True, serializer.data
        return False, serializer.errors
    
    @staticmethod
    def list_quiz_user_set(user_id,set_id):
        try:
            quiz_user_set = Quiz_User_Set.objects.get(user_id=user_id, set_id=set_id)
            return quiz_user_set.quiz_id
        except Quiz_User_Set.DoesNotExist:
            return None
        
    
class QuizViewSet(viewsets.ModelViewSet):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = QuizSerializer
    queryset = Quiz.objects.all()
    
        
    def add_quiz(self,request,set_id = None):
        user_id = User.get_user_id(request.user.username)
        quiz = QuizUserSetService.list_quiz_user_set(user_id,set_id)
        
        if quiz == None : 
            serializer = self.get_serializer(data = request.data)
            if serializer.is_valid():
                quiz_instance = serializer.save()
                quiz_id = quiz_instance.id
                success, response_data = QuizUserSetService.add_quiz_user_set(set_id = set_id,user_id=user_id,quiz_id = quiz_id)
                if success:
                    return Response(serializer.data, status=status.HTTP_201_CREATED)
                else :
                    quiz_instance.delete()
                    return Response(response_data,status=status.HTTP_400_BAD_REQUEST)
        else : 
            print(quiz.id)
            serializer = self.get_serializer(quiz,data=request.data,partial=True)
            if serializer.is_valid():
                print(request.data.get('correct_answer'))
                serializer.save()
            return Response(serializer.data,status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def list_quiz(self,request,set_id = None):
        user_id = User.get_user_id(request.user.username)
        quiz = QuizUserSetService.list_quiz_user_set(user_id,set_id)
        if quiz != None:
            serializer = self.get_serializer(quiz)
            return Response(serializer.data,status=status.HTTP_200_OK)
        return Response(serializer.errors,status=status.HTTP_404_NOT_FOUND)
        
        
class ClassroomUserViewSet(viewsets.ModelViewSet):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = Classroom_User_Serializer
    queryset = classroom_user.objects.all()
    @staticmethod
    def add_admin_2_classroom(classroom_id, user_id, user_role):
        data = {
            'classroom_id': classroom_id,
            'user_id': user_id,
            'user_role': user_role
        }
        serializer = Classroom_User_Serializer(data=data)
        
        if serializer.is_valid():
            serializer.save()
            return True, serializer.data
        return False, serializer.errors
    
    
    def add_user_2_classroom(self,request):
        user_id = User.get_user_id(request.user.username)
        
        classroom = Classroom.objects.get(id=request.data.get('classroom_id'))
        if classroom:
            serializer = self.get_serializer(data = {'classroom_id':classroom.id, 'user_id': user_id, 'user_role': False })
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data,status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
            
            
    def list_users_classrooms(self,request):

        user_id = User.get_user_id(request.user.username)
        print(user_id)
        
        classrooms = Classroom.objects.raw("""
            SELECT 
                c.*, 
                (SELECT COUNT(*) 
                FROM quizhoot_classroom_user cu 
                WHERE cu.classroom_id = c.id) AS size,
                usr.username AS creator_username
            FROM 
                quizhoot_classroom c
            INNER JOIN 
                quizhoot_classroom_user u 
            ON 
                c.id = u.classroom_id
            INNER JOIN 
                quizhoot_user usr 
            ON 
                c.creator_id = usr.id
            WHERE 
                u.user_id = %s   
            """, [user_id])
        
   
        serializer = Classroom_Serializer(classrooms, many = True)
        print("classroom_size : ",serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'], url_path='list')
    def list_members_of_classrooms(self,request,classroom_id = None):
        classroom = Classroom.objects.get(id = classroom_id)
        if classroom : 
            members = classroom_user.objects.raw("""
                                                SELECT cu.id, u.username as member_username, cu.user_role FROM quizhoot_classroom_user cu INNER JOIN quizhoot_user u on cu.user_id = u.id WHERE cu.classroom_id = %s
                                                """,[classroom_id])
            
            serializer = Classroom_User_Serializer(members,many = True)
            return Response(serializer.data,status=status.HTTP_200_OK)
        else :
            Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
            
    """@staticmethod
    def update_user_role(self,classroom_id, user_id, new_role):
        try:
            classroom_user = classroom_user.objects.get(classroom_id=classroom_id, user_id=user_id)
            classroom_user.user_role = new_role
            classroom_user.save()
            return True, "User role updated successfully :)"
        except classroom_user.DoesNotExist:
            return False, "Classroom user not found!!!!"
        except Exception as e:
            return False, str(e)
"""

    def delete_user_from_classroom(self,request,classroom_id = None):
        try:        
            user_id = User.get_user_id(request.user.username)
            print(classroom_id)
            print(user_id)
            classroom_user_obj = classroom_user.objects.get(classroom_id=classroom_id, user_id=user_id)
            classroom_user_obj.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            print(e)
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
        
        
class ClassroomViewSet(viewsets.ModelViewSet):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = Classroom_Serializer
    queryset = Classroom.objects.all()

    @action(detail=False, methods=['post'], url_path='add')
    def add_classroom(self, request):
        user_id = User.get_user_id(request.user.username)
        serializer = self.get_serializer(data={
            'classroom_name': request.data.get('classroom_name'),
            'creator_id': user_id
        })
        if serializer.is_valid():
            classroom_instance = serializer.save()
            classroom_id = classroom_instance.id
            success,response_data = ClassroomUserViewSet.add_admin_2_classroom(classroom_id=classroom_id,user_id=user_id,user_role=True)
            if success:
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                classroom_instance.delete()
                return Response(response_data,status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'], url_path='list')
    def list_classrooms(self, request):
        classrooms = self.get_queryset()

        # Prepare an empty list to hold the classroom data with size and creator_name
        classroom_data = []

        for classroom in classrooms:
            # Calculate the size (number of students in the classroom)
            size = classroom_user.objects.filter(classroom_id=classroom.id).count()
            
            # Get the creator's name (assuming `creator_id` points to a User model)
            creator_name = Classroom.objects.get(id=classroom.id)
            creator_name = creator_name.creator_id.username if creator_name else None
            
            # Add the classroom data, including size and creator_name
            classroom_data.append({
                "id": classroom.id,
                "classroom_name": classroom.classroom_name,
                "size": size,
                "creator_username": creator_name,
            })
        # Return the serialized data in the response
        return Response(classroom_data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_classroom(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk, creator_id=request.user.id)
            classroom.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['put'], url_path='update')
    def update_classroom(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk, creator_id=request.user.id)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(classroom, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'], url_path='add-set')
    def add_set_to_classroom(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
        set_id = request.data.get('set_id')
        try:
            set_instance = Set.objects.get(pk=set_id)
            classroom.sets.add(set_instance)
            return Response({"message": "Set added to classroom successfully."}, status=status.HTTP_200_OK)
        except Set.DoesNotExist:
            return Response({"error": "Set not found."}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['delete'], url_path='remove-set')
    def remove_set_from_classroom(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
        set_id = request.data.get('set_id')
        try:
            set_instance = Set.objects.get(pk=set_id)
            classroom.sets.remove(set_instance)
            return Response({"message": "Set removed from classroom successfully."}, status=status.HTTP_200_OK)
        except Set.DoesNotExist:
            return Response({"error": "Set not found."}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['post'], url_path='add-folder')
    def add_folder_to_classroom(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
        folder_id = request.data.get('folder_id')
        try:
            folder_instance = Folder.objects.get(pk=folder_id)
            classroom.folders.add(folder_instance)
            return Response({"message": "Folder added to classroom successfully."}, status=status.HTTP_200_OK)
        except Folder.DoesNotExist:
            return Response({"error": "Folder not found."}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['delete'], url_path='remove-folder')
    def remove_folder_from_classroom(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
        folder_id = request.data.get('folder_id')
        try:
            folder_instance = Folder.objects.get(pk=folder_id)
            classroom.folders.remove(folder_instance)
            return Response({"message": "Folder removed from classroom successfully."}, status=status.HTTP_200_OK)
        except Folder.DoesNotExist:
            return Response({"error": "Folder not found."}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['get'], url_path='list-sets-folders')
    def list_sets_and_folders(self, request, pk=None):
        try:
            classroom = Classroom.objects.get(pk=pk)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
        sets = classroom.sets.all()
        folders = classroom.folders.all()

        sets_data = [{"id": s.id, "set_name": s.set_name, "size":s.size} for s in sets]
        folders_data = [{"id": f.id, "folder_name": f.folder_name,"size":f.sets.count()} for f in folders]

        return Response({
            "sets": sets_data,
            "folders": folders_data
        }, status=status.HTTP_200_OK)
        
    """@action(detail=True, methods=['put'], url_path='update')
    def update_user_role(self,request):
        classroom_id = request.data.get("classroom_id")
        user_id = request.data.get("user_id")
        new_role = request.data.get("new_role")
        success, response_data = ClassroomUserService.update_user_role(classroom_id=classroom_id,user_id=user_id,new_role=new_role)
        if success:
            return Response(response_data,status=status.HTTP_200_OK)
        else:
            return Response(response_data,status=status.HTTP_400_BAD_REQUEST)
        
    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_user(self,request):
        classroom_id = request.data.get("classroom_id")
        user_id = request.data.get("user_id")
        success, response_data = ClassroomUserService.delete_user_from_classroom(classroom_id=classroom_id,user_id=user_id)
        if success:
            return Response(response_data,status=status.HTTP_200_OK)
        else:
            return Response(response_data,status=status.HTTP_400_BAD_REQUEST)"""
            
            
            
    
class FolderViewSet(viewsets.ModelViewSet):
    """
    ViewSet to handle CRUD operations for Folders,
    plus adding/removing/listing sets within a folder.
    """
    serializer_class = FolderSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Return only folders belonging to the authenticated user
        return Folder.objects.filter(user_id=self.request.user.id)

    # --------------------------------------------------------------------------
    # CREATE a new folder
    # POST /folders/create/
    # Body: { "name": "Folder Name", "sets": [set_id1, set_id2, ...] (optional) }
    # --------------------------------------------------------------------------
    @action(detail=False, methods=['post'], url_path='create')
    def create_folder(self, request):
        user_id = User.get_user_id(request.user.username)
        if not user_id:
            return Response({"error": "Invalid user"}, status=status.HTTP_400_BAD_REQUEST)

        data = request.data.copy()
        data['user_id'] = user_id  # Assign the folder to the current user

        serializer = self.get_serializer(data=data)
        if serializer.is_valid():
            folder = serializer.save()
            return Response(
                self.get_serializer(folder).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # --------------------------------------------------------------------------
    # LIST all folders (for this user)
    # GET /folders/list/
    # --------------------------------------------------------------------------
    @action(detail=False, methods=['get'], url_path='list')
    def list_folders(self, request):
        folders = self.get_queryset()
        serializer = self.get_serializer(folders, many=True)
        print(serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK)

    # --------------------------------------------------------------------------
    # RENAME folder (custom partial update just for 'name')
    # PUT /folders/<pk>/rename/
    # Body: { "name": "New Folder Name" }
    # --------------------------------------------------------------------------
    @action(detail=True, methods=['put'], url_path='rename')
    def rename_folder(self, request, pk=None):
        try:
            folder = Folder.objects.get(pk=pk, user_id=request.user.id)
        except Folder.DoesNotExist:
            return Response(
                {"error": "Folder not found or not yours"},
                status=status.HTTP_404_NOT_FOUND
            )

        new_name = request.data.get('folder_name')
        if not new_name:
            return Response(
                {"error": "Name is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        folder.folder_name = new_name
        folder.save()
        return Response(self.get_serializer(folder).data, status=status.HTTP_200_OK)

    # --------------------------------------------------------------------------
    # DELETE folder
    # DELETE /folders/<pk>/
    # --------------------------------------------------------------------------
    def destroy(self, request, *args, **kwargs):
        try:
            folder = Folder.objects.get(pk=kwargs['pk'], user_id=request.user.id)
        except Folder.DoesNotExist:
            return Response(
                {"error": "Folder not found or not yours"},
                status=status.HTTP_404_NOT_FOUND
            )
        folder.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    # ==========================================================================
    # NEW ACTIONS:
    # ==========================================================================
    # 5) ADD A SET to a folder
    # POST /folders/<pk>/add_set/
    # Body: { "set_id": <some_set_id> }
    # ==========================================================================
    @action(detail=True, methods=['post'], url_path='add_set')
    def add_set_to_folder(self, request, pk=None):
        try:
            folder = Folder.objects.get(pk=pk, user_id=request.user.id)
        except Folder.DoesNotExist:
            return Response(
                {"error": "Folder not found or not yours"},
                status=status.HTTP_404_NOT_FOUND
            )

        set_id = request.data.get('set_id')
        if not set_id:
            return Response({"error": "set_id is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            set_obj = Set.objects.get(id=set_id)
        except Set.DoesNotExist:
            return Response({"error": "Set not found"}, status=status.HTTP_404_NOT_FOUND)

        # Because we use a ManyToMany relation or a many-to-many field:
        folder.sets.add(set_obj)
        folder.save()

        return Response({"message": f"Set {set_id} added to folder {pk}"}, status=status.HTTP_200_OK)

    # ==========================================================================
    # 6) REMOVE A SET from this folder
    # DELETE /folders/<pk>/remove_set/<set_id>/
    # ==========================================================================
    @action(detail=True, methods=['delete'], url_path='remove_set/(?P<set_id>[^/.]+)')
    def remove_set_from_folder(self, request, pk=None, set_id=None):
        try:
            folder = Folder.objects.get(pk=pk, user_id=request.user.id)
        except Folder.DoesNotExist:
            return Response(
                {"error": "Folder not found or not yours"},
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            set_obj = Set.objects.get(id=set_id)
        except Set.DoesNotExist:
            return Response({"error": "Set not found"}, status=status.HTTP_404_NOT_FOUND)

        folder.sets.remove(set_obj)
        folder.save()

        return Response({"message": f"Set {set_id} removed from folder {pk}"}, status=status.HTTP_200_OK)

    # ==========================================================================
    # 7) LIST ALL SETS within this folder
    # GET /folders/<pk>/sets/
    # ==========================================================================
    @action(detail=True, methods=['get'], url_path='sets')
    def list_sets_in_folder(self, request, pk=None):
        try:
            folder = Folder.objects.get(pk=pk)
        except Folder.DoesNotExist:
            return Response(
                {"error": "Folder not found or not yours"},
                status=status.HTTP_404_NOT_FOUND
            )

        # Get all sets in this folder
        sets = folder.sets.all()
        serializer = SetSerializer(sets, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    
class NotificationViewSet(viewsets.ModelViewSet):
    """
    ViewSet for handling CRUD operations for the Notification model.
    """
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = NotificationSerializer
    queryset = Notification.objects.all()
    # List notifications for a specific classroom
    @action(detail=False, methods=['get'], url_path='classroom/<classroom_id>/list')
    def list_notifications_by_classroom(self, request, classroom_id=None):
        try:
            # Fetch classroom
            classroom = Classroom.objects.get(id=classroom_id)                
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)
     # Get notifications for the specific classroom
        notifications = Notification.objects.filter(classroom=classroom)
        
        # Serialize the notifications data
        serializer = NotificationSerializer(notifications, many=True)
        
        # Return the serialized data with the message, username, and created_at
        return Response(serializer.data, status=status.HTTP_200_OK)

    # Create a new notification
    @action(detail=False, methods=['post'], url_path='create')
    def create_notification(self, request):
        # Ensure required fields are provided
        user_id = User.get_user_id(request.user.username)
        classroom_id = request.data.get('classroom_id')
        message = request.data.get('message')
        notification_type = 'Custom notification'
        print(classroom_id,message,notification_type)
        if not classroom_id or not message or not notification_type:
            return Response({"error": "classroom_id, message, and notification_type are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id = user_id)
            classroom = Classroom.objects.get(id=classroom_id)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)

        # Create the notification
        notification = Notification.objects.create(
            user=user,
            classroom=classroom,
            message=message,
            notification_type=notification_type,
        )
        
        classroom_users = classroom.users.exclude(id=user_id)
        notification.users.set(classroom_users)
        serializer = NotificationSerializer(notification)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    # Custom delete for a notification
    @action(detail=True, methods=['delete'], url_path='delete')
    def delete_notification(self, request, pk=None):
        try:
            notification = Notification.objects.get(pk=pk)
            notification.delete()
            return Response({"message": "Notification deleted successfully"}, status=status.HTTP_200_OK)
        except Notification.DoesNotExist:
            return Response({"error": "Notification not found"}, status=status.HTTP_404_NOT_FOUND)
        
    @action(detail=False, methods=['delete'], url_path='remove_user')
    def remove_user_from_notification(self, request, notification_id=None ):
        user_id = User.get_user_id(request.user.username)

        if not notification_id or not user_id:
            return Response({"error": "notification_id and user_id are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            notification = Notification.objects.get(id=notification_id)
            user = User.objects.get(id=user_id)
        except Notification.DoesNotExist:
            return Response({"error": "Notification not found"}, status=status.HTTP_404_NOT_FOUND)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        # Remove the user from the notification's users
        notification.users.remove(user)

        return Response({"success": "User removed from notification"}, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='user_notifications')
    def list_user_notifications(self, request):
        # Get the authenticated user
        user = User.objects.get(username=request.user.username)
        print(user.username)
        # Fetch notifications where the user is in the many-to-many field 'users'
        notifications = Notification.objects.filter(users=user)
        print(notifications)
        # Serialize the notifications
        serializer = NotificationSerializer(notifications, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    
class MessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing messages within classrooms.
    """
    authentication_classes = [TokenAuthentication]
    #permission_classes = [IsAuthenticated]
    serializer_class = MessageSerializer
    queryset = Message.objects.all()  # Add this line to define the default queryset

    @action(detail=False, methods=['get'], url_path='list')
    def list_messages(self, request):
        """
        List all messages for a specific classroom.
        """
        classroom_id = request.query_params.get('classroom_id')
        if not classroom_id:
            return Response({"error": "classroom_id is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            classroom = Classroom.objects.get(id=classroom_id)
        except Classroom.DoesNotExist:
            return Response({"error": "Classroom not found"}, status=status.HTTP_404_NOT_FOUND)

        messages = Message.objects.filter(classroom=classroom)
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'], url_path='create')
    def create_message(self, request):
        """
        Create a new message for a specific classroom.
        """
        serializer = MessageSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

