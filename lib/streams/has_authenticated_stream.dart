import 'dart:async';

class HasAuthenticatedClass{
  final String url;
  final String codeVerifier;

  HasAuthenticatedClass(
    this.url,
    this.codeVerifier
  );
}

class HasAuthenticatedStreamClass {
  static final HasAuthenticatedStreamClass _instance = HasAuthenticatedStreamClass._internal();
  late StreamController<HasAuthenticatedClass> _updateHasAuthenticated;

  factory HasAuthenticatedStreamClass(){
    return _instance;
  }

  HasAuthenticatedStreamClass._internal() {
    _updateHasAuthenticated = StreamController<HasAuthenticatedClass>.broadcast();
  }

  Stream<HasAuthenticatedClass> get hasAuthenticatedStream => _updateHasAuthenticated.stream;


  void removeListener(){
    _updateHasAuthenticated.stream.drain();
  }

  void emitData(HasAuthenticatedClass data){
    if(!_updateHasAuthenticated.isClosed){
      _updateHasAuthenticated.add(data);
    }
  }

  void dispose(){
    _updateHasAuthenticated.close();
  }
}