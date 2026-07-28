from cryptography.fernet import Fernet

def generate_key() -> bytes:
    """Generate a new encryption key"""
    return Fernet.generate_key()

def encrypt_data(key: bytes, data: str) -> bytes:
    """Encrypt string data"""
    f = Fernet(key)
    return f.encrypt(data.encode())

def decrypt_data(key: bytes, token: bytes) -> str:
    """Decrypt string data"""
    f = Fernet(key)
    return f.decrypt(token).decode()

def encrypt_bytes(key: bytes, data: bytes) -> bytes:
    """Encrypt binary data (media files)"""
    f = Fernet(key)
    return f.encrypt(data)

def decrypt_bytes(key: bytes, token: bytes) -> bytes:
    """Decrypt binary data (media files)"""
    f = Fernet(key)
    return f.decrypt(token)

