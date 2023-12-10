enum DataType {
  //JSON data
  json,
  template,
  systemData,
  userDataRSync, //Remote Synchronization
  virtual,
  socket,
  //NOT JSON data
  js,
  any,
  blobRSync, //Base64 large object Remote Synchronization
  blob;

  bool isJson() {
    return ![js, any, blob, blobRSync].contains(this);
  }
}
