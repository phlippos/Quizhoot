from rest_framework import serializers
from .models import User,Set,Flashcard,Set_Flashcard,Quiz,Quiz_User_Set,Classroom,classroom_user,Folder,Message

"""
    Django'da serialization, Django modellerini (veya queryset'lerini) JSON, XML veya diğer biçimlere dönüştürmeyi sağlar.
    Bu, verilerin web API'leri aracılığıyla dışa aktarılması veya başka sistemlere iletilmesi gibi durumlar için faydalıdır.
    Django'nun yerleşik serializers modülü temel serialization işlemlerini sağlar, ancak daha karmaşık ihtiyaçlar için Django REST framework (DRF) kullanmak genellikle tercih edilir.
"""
    
class UserSerializer(serializers.ModelSerializer):
    
    class Meta:
        """
        class Meta iç sınıfı, Django'da ve Django REST Framework (DRF) içinde model ve serializer tanımlarında sıkça kullanılan bir kalıptır.
        Meta sınıfı, modelin veya serializer'ın meta verilerini yani yapılandırma seçeneklerini belirtmek için kullanılır.
            - model: Hangi modelin seri hale getirileceğini belirtir.
            - fields: Hangi model alanlarının seri hale getirileceğini belirtir.
            
            
            Django Model Meta Seçenekleri
                db_table: Veritabanı tablosunun adını belirler.
                ordering: Varsayılan sıralama düzenini belirler.
                verbose_name: Modelin tekil adı.
                verbose_name_plural: Modelin çoğul adı.
                unique_together: Alanların birlikte benzersiz olmasını sağlar.
                
            Django REST Framework Serializer Meta Seçenekleri
                model: Hangi modelin seri hale getirileceğini belirtir.
                fields: Seri hale getirilecek model alanlarının bir listesi.
                exclude: Hariç tutulacak model alanlarının bir listesi.
                read_only_fields: Sadece okunabilir alanların bir listesi.
                extra_kwargs: Alanlar için ek argümanlar belirtir.
        """ 
        model = User
        fields = ["id","email","password","username","first_name", "last_name", "phone_number","mindfulness"]

class SetSerializer(serializers.ModelSerializer):
    createdBy = serializers.SerializerMethodField()

    class Meta:
        model = Set
        fields = '__all__'  

    def get_createdBy(self, obj):     
        return obj.user_id.username if obj.user_id else None
    
class FlashcardSerializer(serializers.ModelSerializer):
    fav = serializers.BooleanField(source='fav_word', read_only=True)
    class Meta:
        model = Flashcard
        fields = '__all__'
         

class Set_FlashcardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Set_Flashcard
        fields = '__all__'
        
        
class QuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quiz
        fields = '__all__'
        
class Quiz_User_SetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quiz_User_Set
        fields = '__all__'
         
class Classroom_Serializer(serializers.ModelSerializer):
    size = serializers.IntegerField(read_only=True)
    creator_username = serializers.CharField(read_only=True)
    class Meta:
        model = Classroom
        fields = '__all__'
        
class Classroom_User_Serializer(serializers.ModelSerializer):
    size = serializers.IntegerField(read_only=True)
    creator_username = serializers.CharField(read_only=True)
    member_username = serializers.CharField(read_only=True)
    class Meta:
        model = classroom_user
        fields = '__all__'
        
        
class FolderSerializer(serializers.ModelSerializer):
    # This will display a list of Set IDs
    sets = serializers.PrimaryKeyRelatedField(
        many=True, 
        queryset=Set.objects.all(), 
        required=False
    )
    
    class Meta:
        model = Folder
        fields = ['id', 'user_id', 'folder_name', 'sets']


class MessageSerializer(serializers.ModelSerializer):
    sender_username = serializers.CharField(source='sender.username', read_only=True)

    class Meta:
        model = Message
        fields = '__all__'
        read_only_fields = ['timestamp']

