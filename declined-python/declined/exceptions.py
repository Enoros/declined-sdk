class DeclinedError(Exception):
  def __init__(self, status: int, message: str, code: str | None = None):
    super().__init__(message)
    self.status = status
    self.code = code
