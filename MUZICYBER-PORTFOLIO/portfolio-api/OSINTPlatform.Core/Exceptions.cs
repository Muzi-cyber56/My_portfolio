namespace OSINTPlatform.Core;
public sealed class ValidationException(string message) : Exception(message);
public sealed class MissingException(string message = "Resource not found.") : Exception(message);
public sealed class ConflictException(string message) : Exception(message);
