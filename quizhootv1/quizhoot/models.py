from django.db import models
from django.contrib.auth.models import AbstractUser
"""
Django'da models.py, veritabanı tablosunu temsil eden Python sınıflarının bulunduğu yerdir.
Bu sınıflar, Django ORM (Object-Relational Mapping) kullanarak veritabanında verileri depolamak ve almak için kullanılır.

"""
# Create your models here.
class User(AbstractUser):
    phone_number = models.CharField(max_length=255,db_column="phone_number")
    mindfulness = models.IntegerField(null=True, db_column="mindfulness",default=1)
    
    
class Set(models.Model):
    set_name = models.CharField(max_length=255, db_column="set_name", null=False)
    description = models.TextField(null=True, blank=True, db_column="description")
    user_id = models.ForeignKey(User, on_delete=models.CASCADE, db_column="user_id")  # ForeignKey relation with User
    share = models.BooleanField(default=False, db_column="share")  # Defaults to 0 (False)
    tags = models.CharField(max_length=255, null=True, blank=True, db_column="tags")
    language = models.CharField(max_length=50, null=True, blank=True, db_column="language")
    rating = models.FloatField(null=True, blank=True, db_column="rating")
    size = models.IntegerField(null=True, blank=True, db_column="size")

    class Meta:
        db_table = "Set"

    def __str__(self):
        return f"{self.set_name} (User ID: {self.user_id.id})"