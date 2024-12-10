from django.db import models
from django.contrib.auth.models import AbstractUser
"""
Django'da models.py, veritabanı tablosunu temsil eden Python sınıflarının bulunduğu yerdir.
Bu sınıflar, Django ORM (Object-Relational Mapping) kullanarak veritabanında verileri depolamak ve almak için kullanılır.

"""
# Create your models here.
class User(AbstractUser):
    phone_number = models.CharField(max_length=255,db_column="phone_number")
    mindfulness = models.IntegerField(null=True, db_column="mindfulness",default=0)
    
    @staticmethod
    def get_user_id(username):
        try:
            user = User.objects.get(username=username)
            return user.id
        except User.DoesNotExist:
            return None

    
class Set(models.Model):
    set_name = models.CharField(max_length=255, db_column="set_name", null=False)
    description = models.TextField(null=True, blank=True, db_column="description")
    user_id = models.ForeignKey(User, on_delete=models.CASCADE, db_column="user_id")  # ForeignKey relation with User
    share = models.BooleanField(default=False, db_column="share")  # Defaults to 0 (False)
    tags = models.CharField(max_length=255, null=True, blank=True, db_column="tags")
    language = models.CharField(max_length=50, null=True, blank=True, db_column="language")
    rating = models.FloatField(null=True, blank=True, db_column="rating")
    size = models.IntegerField(null=True, blank=True, db_column="size",default = 0)
    flashcards = models.ManyToManyField('Flashcard', through='Set_Flashcard', related_name='sets')
    
    class Meta:
        db_table = "Set"

    def __str__(self):
        return f"{self.set_name} (User ID: {self.user_id.id})"

class Flashcard(models.Model):
    term = models.CharField(max_length=255,db_column="term",null=False)
    definition = models.CharField(max_length=255,db_column="definition",null=False)
    
    class Meta:
        db_table = "Flashcard"

class Set_Flashcard(models.Model):
    set_id = models.ForeignKey(Set,on_delete=models.CASCADE,db_column="set_id")
    flashcard_id = models.ForeignKey(Flashcard,on_delete=models.CASCADE,db_column="flashcard_id")
    user_id = models.ForeignKey(User,on_delete=models.CASCADE,db_column="user_id")
    fav = models.BooleanField(db_column="fav_word",default=False)
    
    
    
class Quiz(models.Model):
    result = models.FloatField(null=False,db_column="result")
    correct_answer = models.IntegerField(null=False,db_column="correct_answer")
    incorrect_answer = models.IntegerField(null=False,db_column="incorrect_answer")
    quiz_type = models.BooleanField(null=False,db_column="quiz_type")
    
    
class Quiz_User_Set(models.Model):
    user_id = models.ForeignKey(User,on_delete=models.CASCADE,db_column="user_id")
    set_id = models.ForeignKey(Set,on_delete=models.CASCADE,db_column="set_id")
    quiz_id = models.ForeignKey(Quiz,on_delete=models.CASCADE,db_column="quiz_id")
    