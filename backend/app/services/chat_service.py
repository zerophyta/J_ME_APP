from app.utils.crypto import encrypt_data, decrypt_data

class ChatService:
    def __init__(self, chat_key: bytes):
        # one key per chat
        self.chat_key = chat_key

    def send_message(self, message: str) -> bytes:
        """Encrypt message before saving to DB"""
        return encrypt_data(self.chat_key, message)

    def read_message(self, encrypted: bytes) -> str:
        """Decrypt message after fetching from DB"""
        return decrypt_data(self.chat_key, encrypted)

