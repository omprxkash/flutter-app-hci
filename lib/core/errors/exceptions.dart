/// Exceptions thrown *only* inside the data layer. They are caught at the
/// data/domain boundary and converted to `Failure` values. Domain and
/// presentation code should never throw or catch these directly.

class DataLayerException implements Exception {
  const DataLayerException(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class FirestoreException extends DataLayerException {
  const FirestoreException(super.message, [super.cause]);
}

class FirebaseAuthInternalException extends DataLayerException {
  const FirebaseAuthInternalException(super.message, [super.cause, this.code]);
  final String? code;
}

class CacheException extends DataLayerException {
  const CacheException(super.message, [super.cause]);
}

class ParsingException extends DataLayerException {
  const ParsingException(super.message, [super.cause]);
}
