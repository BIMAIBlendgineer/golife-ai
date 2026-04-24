from __future__ import annotations

from cryptography.fernet import Fernet, InvalidToken


class SecretBox:
    def __init__(self, master_key: str):
        try:
            self._fernet = Fernet(master_key.encode("utf-8"))
        except Exception as exc:  # pragma: no cover - invalid config
            raise ValueError("Invalid OPENROUTER_KEYS_MASTER_KEY for Fernet.") from exc

    def encrypt(self, value: str) -> str:
        return self._fernet.encrypt(value.encode("utf-8")).decode("utf-8")

    def decrypt(self, value: str) -> str:
        try:
            return self._fernet.decrypt(value.encode("utf-8")).decode("utf-8")
        except InvalidToken as exc:  # pragma: no cover - corrupted data
            raise ValueError("Stored key ciphertext could not be decrypted.") from exc

    @staticmethod
    def secret_last4(value: str) -> str:
        return value[-4:] if len(value) >= 4 else value

