import asyncio
import websockets

async def test_websocket():
    uri = "ws://127.0.0.1:8000/ws/chat/1/"
    try:
        async with websockets.connect(uri) as websocket:
            await websocket.send("Hello, WebSocket!")
            response = await websocket.recv()
            print(response)
    except Exception as e:
        print(f"WebSocket connection failed: {e}")

loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)
loop.run_until_complete(test_websocket())
