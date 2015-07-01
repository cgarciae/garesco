part of garesco.email.server;

@Injectable()
@app.Group ('/files')
class FileServices extends GenericRethinkServices<FileDb> {

  FileServices(InjectableRethinkConnection irc) : super (Col.files, irc);

  Future<FileDb> newFile (HttpBodyFileUpload file) async {
    var fileDb = new FileDb()
      ..id = new uuid.Uuid().v1()
      ..contentType = file.contentType.value;

    await writeFile(fileDb.id, file.content);
    await insertNow(fileDb);

    return fileDb;
  }

  Future writeFile (String id, List<int> data) async {
    var file = new File('${path.current}/${Col.files}/$id');
    await file.writeAsBytes(data);
  }

  Stream<List<int>> readFile (String id) async * {
    var file = new File("${path.current}/${Col.files}/$id");
    yield * file.openRead();
  }

  @app.Route ('/:id')
  Future<shelf.Response> downloadFile (String id) async {
    try {
      var metadata = await getMetadata(id);
      return new shelf.Response.ok(readFile(id), headers: {"Content-Type": metadata.contentType});
    }
    catch (e,s) {
      return new shelf.Response.ok("Server Error: $e \n $s");
    }
  }

  Future<FileDb> insertMetadata (FileDb metadata) async {
    var resp = await insertNow(metadata);

    if (resp['inserted'] == 0)
      throw new app.ErrorResponse (400, {'error': 'Metadata no insertada'});

    return metadata..id = resp['generated_keys'].first;
  }

  Future<FileDb> getMetadata(String id) async {
    var metadata = await getNow(id);
    if (metadata == null) throw new app.ErrorResponse(
        400, "El archivo no existe");
    return metadata;
  }

  Future<FileDb> updateMetadata (String id, FileDb delta) async {
    Map resp = await updateNow(id, delta);
    return getMetadata(id);
  }

  Future deleteFile(String id) async {
    var file = new File("${path.current}/${Col.files}/$id");
    await file.delete();
  }

  Future deleteMetadata(String id) async {
    return deleteNow(id);
  }

}