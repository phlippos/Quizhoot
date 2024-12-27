# consumers.py
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from asgiref.sync import sync_to_async
import json
from .models import Message, Classroom, classroom_user, User

class ClassroomChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        
        self.classroom_id = self.scope['url_route']['kwargs']['classroom_id']
        self.room_group_name = f'chat_classroom_{self.classroom_id}'

        # Verify classroom exists and user has access
        if not await self.verify_access():
            await self.close()
            return
        
        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    @database_sync_to_async
    def verify_access(self):
        try:
            user = self.scope["user"]
            if not user.is_authenticated:
                return False
            
            classroom = Classroom.objects.get(id=self.classroom_id)
            return classroom_user.objects.filter(
                classroom_id=classroom,
                user_id=user
            ).exists()
        except (Classroom.DoesNotExist, Exception):
            return False

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            message = data['message']
            
            # Save message to database
            message_obj = await self.save_message(message)
            
            if message_obj:
                # Send message to room group
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'chat_message',
                        'message': message,
                        'username': self.scope["user"].username,
                        'timestamp': message_obj.timestamp.isoformat(),
                    }
                )
        except json.JSONDecodeError:
            pass
        except KeyError:
            pass

    @database_sync_to_async
    def save_message(self, message_content):
        try:
            classroom = Classroom.objects.get(id=self.classroom_id)
            return Message.objects.create(
                classroom=classroom,
                sender=self.scope["user"],
                content=message_content
            )
        except Classroom.DoesNotExist:
            return None

    async def chat_message(self, event):
        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'message': event['message'],
            'username': event['username'],
            'timestamp': event['timestamp'],
        }))