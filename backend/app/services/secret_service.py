from app.utils.crypto import generate_key, encrypt_data, decrypt_data, encrypt_bytes, decrypt_bytes

class SecretService:
    def send_secret_message(self, message: str):
        """Generate new key per message and encrypt"""
        key = generate_key()
        encrypted = encrypt_data(key, message)
        return encrypted, key

    def read_secret_message(self, encrypted: bytes, key: bytes) -> str:
        """Decrypt secret message"""
        return decrypt_data(key, encrypted)

    def send_secret_media(self, file_bytes: bytes):
        """Generate new key per media and encrypt"""
        key = generate_key()
        encrypted = encrypt_bytes(key, file_bytes)
        return encrypted, key

    def read_secret_media(self, encrypted: bytes, key: bytes) -> bytes:
        """Decrypt secret media"""
        return decrypt_bytes(key, encrypted)

