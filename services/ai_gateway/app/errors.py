class AITemporarilyUnavailableError(RuntimeError):
    def __init__(self, message: str = "ai_temporarily_unavailable") -> None:
        super().__init__(message)
        self.code = "ai_temporarily_unavailable"
