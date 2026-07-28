from app.utils.crypto import encrypt_bytes, decrypt_bytes

class MediaService:
    def __init__(self, chat_key: bytes):
        # use chat key for normal media
        self.chat_key = chat_key

    def save_media(self, file_bytes: bytes) -> bytes:
        """Encrypt media before saving"""
        return encrypt_bytes(self.chat_key, file_bytes)

    def load_media(self, encrypted: bytes) -> bytes:
        """Decrypt media after fetching"""
        return decrypt_bytes(self.chat_key, encrypted)

