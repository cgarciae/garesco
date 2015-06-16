part of garesco.email.server;

@mvc.GroupController('/admin/maquinas', root: '/lib/views')
class AdminMaquinaServices extends RethinkServices<Maquina> {
  FileServices fileServices;

  AdminMaquinaServices(this.fileServices) : super('maquinas');
  AdminMaquinaServices.fromConnection(Connection conn)
      : super.fromConnection('maquinas', conn);

  @mvc.ViewController('/agregar', methods: const [app.GET])
  agregarForm() async {
    return {};
  }

  @mvc.ViewController('/agregar',
      methods: const [app.POST], allowMultipartRequest: true)
  agregar(@app.Body(app.FORM) QueryMap form) async {
    Maquina maquina = decode(form, Maquina);
    maquina.id = new uuid.Uuid().v1();

    if (form.archivosImagenes != null) {
      List<app.HttpBodyFileUpload> images = form.archivosImagenes is List
          ? form.archivosImagenes
          : [form.archivosImagenes];

      maquina.imagenes = new List<FileDb>();
      for (var file in images) {
        var fileDb = await fileServices.newFile(file);
        maquina.imagenes.add(fileDb);
      }
    }
    await insertNow(maquina);

    app.redirect("/admin/maquinas/${maquina.id}");
  }

  @mvc.ViewController("/:id",
      filePath: '/admin/maquinas/agregar', methods: const [app.GET])
  Future<Maquina> getMaquina(String id) async {
    return getNow(id);
  }

  @mvc.DataController('/nueva', methods: const [app.POST])
  Future<Maquina> nueva() => agregar(new Maquina()
    ..aNo = ""
    ..descripcion = ""
    ..modelo = ""
    ..pais = ""
    ..precio = ""
    ..venta = ""
    ..link = "");

  @mvc.DataController('/:id', methods: const [app.PUT])
  Future<Maquina> actualizar(String id, @Decode() Maquina maquina) async {
    maquina.id = null;
    await updateNow(id, maquina);
    return obtener(id);
  }

  @mvc.DataController('/:id', methods: const [app.DELETE])
  Future eliminar(String id) async {
    await deleteNow(id);
  }

  @mvc.DataController('/todas')
  Future<List<Maquina>> todas() async {
    Cursor result = await this.run(conn);
    List<Map> list = await result.toArray();
    return list.map((m) => decode(m, Maquina)).toList();
  }
}
