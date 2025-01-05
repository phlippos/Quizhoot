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
    
    
    
class Classroom(models.Model):
    classroom_name = models.CharField(max_length=255, db_column="classroom_name", null=False)
    creator_id = models.ForeignKey(User,on_delete = models.CASCADE,db_column = "creator_id")
    sets = models.ManyToManyField('Set', blank=True, related_name='classrooms')
    folders = models.ManyToManyField('Folder', blank=True, related_name='classrooms')
    users = models.ManyToManyField(User, through='classroom_user', related_name='classrooms')
    
class classroom_user(models.Model):
    classroom_id = models.ForeignKey(Classroom,on_delete = models.CASCADE,db_column = "classroom_id")
    user_id = models.ForeignKey(User,on_delete = models.CASCADE,db_column = "user_id")
    user_role = models.BooleanField(null=False,db_column="user_role",default = False )


class Message(models.Model):
    classroom = models.ForeignKey(Classroom, on_delete=models.CASCADE, db_column="classroom_id", related_name="messages")
    sender = models.ForeignKey(User, on_delete=models.CASCADE, db_column="sender_id", related_name="sent_messages")
    content = models.TextField(db_column="content")
    timestamp = models.DateTimeField(auto_now_add=True, db_column="timestamp")

    class Meta:
        db_table = "Message"
        ordering = ['-timestamp']  # Newest messages first.

    def __str__(self):
        return f"Message from {self.sender.username} in Classroom {self.classroom.id}"



class Folder(models.Model):
    """
    Each Folder belongs to a User, and can have multiple Sets inside it.
    A Set can also belong to multiple Folders in this scenario.
    """
    user_id = models.ForeignKey(User, on_delete=models.CASCADE, related_name='folders')
    folder_name = models.CharField(max_length=255, db_column="folder_name")

    # Many-to-many relationship with 'Set'
    sets = models.ManyToManyField('Set', blank=True, related_name='folders')
    
    class Meta:
        db_table = "Folder"
    
    def __str__(self):
        return f"{self.name} (Owned by {self.user.username})"
    
    
class Notification(models.Model):
    TYPES = [
        ('join_classroom', 'User joined classroom'),
        ('create_folder', 'Folder created'),
        ('add_set', 'Set added to folder'),
        ('custom', 'Custom notification'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column="user_id")  # The user receiving the notification
    message = models.TextField(db_column="message")  # The content of the notification
    notification_type = models.CharField(max_length=50, choices=TYPES, db_column="notification_type")
    created_at = models.DateTimeField(auto_now_add=True, db_column="created_at")  # Timestamp when the notification was created
    users = models.ManyToManyField(User, related_name='notifications', blank=True)  # Many-to-many field for users
    classroom = models.ForeignKey(
        Classroom, 
        null=True, 
        blank=True, 
        on_delete=models.CASCADE, 
        db_column="classroom_id", 
        related_name='notifications'
    )  # Optional connection to a classroom

    class Meta:
        db_table = "Notification"
        ordering = ['-created_at']  # Order notifications by creation date (latest first)

    def __str__(self):
        return f"Notification for {self.user.username}: {self.message[:50]}..."

    
