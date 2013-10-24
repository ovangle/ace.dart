part of ace;

get _context => js.context;
get _modules => _context['ace']['define']['modules'];

String _ext(String path, {String separator: '.'}) {
  int index = path.lastIndexOf(separator);
  if (index < 0 || index + 1 >= path.length) return path;
  return path.substring(index + 1).toLowerCase();
}

List _list(js.JsObject array) => 
    JSON.decode(_context['JSON'].callMethod('stringify', [array]));

Map _map(js.JsObject obj) => 
    JSON.decode(_context['JSON'].callMethod('stringify', [obj]));

List _spliceList(List list, int start, int howMany, [List elements]) {
  final end = start + howMany;
  final removed = list.sublist(start, end);
  list.removeRange(start, end);
  if (elements != null) {
    list.insertAll(start, elements);
  }
  return removed;
}

abstract class _Disposable {
  /// Dispose of any resources held by this object.
  /// 
  /// This method will release any javascript proxy objects help by this 
  /// object.  It will also close any streams exposed by the object.  It is an
  /// error to call any methods or access any fields of this object after this
  /// method has been called.
  void dispose();
}

abstract class _HasProxy extends _Disposable {
  js.JsObject _proxy;
  
  final Future _onHasProxy;
  
  bool get _hasProxy => _proxy != null;
      
  _HasProxy.async(Future<js.JsObject> proxyFuture) 
      : _onHasProxy = proxyFuture {
    proxyFuture.then((proxy) => _proxy = proxy);
  }
  
  _HasProxy(js.JsObject proxy) 
      : _proxy = proxy
      , _onHasProxy = new Future.value();
  
  call(String name, [List args]) => _proxy.callMethod(name, args);
  
  void dispose() {
    if (_hasProxy) {
      _onDispose();
      _proxy = null;
    }
  }
  
  void _onDispose() {}
  
  String toString() => _context.JSON.stringify(_proxy);  
}
