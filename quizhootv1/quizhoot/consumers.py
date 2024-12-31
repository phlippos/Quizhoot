# consumers.py
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth.models import AnonymousUser
from django.contrib.auth import get_user_model
import jwt
from django.conf import settings
import json
from .models import Message, Classroom, classroom_user
from urllib.parse import parse_qs
from rest_framework.authtoken.models import Token



class ChatAuthMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        query_string = scope["query_string"].decode()
        token = None
        for param in query_string.split("&"):
            if param.startswith("token="):
                token = param.split("=")[1]
                break

        if token:
            try:
                payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
                User = get_user_model()
                user = await database_sync_to_async(User.objects.get)(id=payload["user_id"])
                scope["user"] = user
            except (jwt.InvalidTokenError, User.DoesNotExist) as e:
                print(f"Auth error: {e}")
                scope["user"] = AnonymousUser()
        else:
            scope["user"] = AnonymousUser()

        return await self.app(scope, receive, send)

class ClassroomChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Extract token from query parameters
        token = parse_qs(self.scope["query_string"].decode()).get("token", [None])[0]
        
        if not token:
            print("Missing token in WebSocket connection")
            await self.close()
            return

        # Authenticate user from token
        self.scope["user"] = await self.authenticate_token(token)
        if self.scope["user"] is None or isinstance(self.scope["user"], AnonymousUser):
            print("Invalid or missing token")
            await self.close()
            return

        # Extract classroom ID and verify access
        self.classroom_id = self.scope["url_route"]["kwargs"]["classroom_id"]
        self.room_group_name = f"chat_classroom_{self.classroom_id}"
        
        if not await self.verify_access():
            print(f"Access denied to classroom {self.classroom_id}")
            await self.close()
            return

        # Add to group and accept WebSocket connection
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()
        print(f"WebSocket connected for classroom {self.classroom_id} by user {self.scope['user']}")

    @database_sync_to_async
    def authenticate_token(self, token):
        try:
            return Token.objects.get(key=token).user
        except Token.DoesNotExist:
            return None

    @database_sync_to_async
    def verify_access(self):
        try:
            classroom = Classroom.objects.get(id=self.classroom_id)
            return classroom_user.objects.filter(
                classroom_id=classroom,
                user_id=self.scope["user"]
            ).exists()
        except Classroom.DoesNotExist:
            return False

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
        print(f"WebSocket disconnected with code {close_code}")

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            
            if data.get('type') == 'heartbeat':
                await self.send(text_data=json.dumps({'type': 'heartbeat_response'}))
                return

            message = data.get('message')
            if not message:
                return

            message_obj = await self.save_message(message)
            if message_obj:
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        "type": "chat_message",
                        "message": message,
                        "username": self.scope["user"].username,
                        "timestamp": message_obj.timestamp.isoformat(),
                    }
                )
        except Exception as e:
            print(f"Error in receive: {e}")

    @database_sync_to_async
    def save_message(self, message_content):
        try:
            classroom = Classroom.objects.get(id=self.classroom_id)
            return Message.objects.create(
                classroom=classroom,
                sender=self.scope["user"],
                content=message_content
            )
        except Exception as e:
            print(f"Error saving message: {e}")
            return None

    async def chat_message(self, event):
        try:
            print(f"Sending message to client: {event}")
            await self.send(text_data=json.dumps({
                "content": event["message"],
                "sender_username": event["username"],
                "timestamp": event["timestamp"],
            }))
        except Exception as e:
            print(f"Error in chat_message: {e}")
