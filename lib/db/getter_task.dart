class GetterTask {
  final String _uuid;
  final Function _handler;

  GetterTask(this._uuid, this._handler);

  Function get handler => _handler;

  String get uuid => _uuid;
}
