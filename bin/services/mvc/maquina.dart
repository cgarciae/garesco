part of garesco.email.server;

@mvc.GroupController('/admin/maquinas', root: '/html')
class AdminMaquinaController extends RethinkServices<Maquina> {
  FileServices fileServices;

  AdminMaquinaController(this.fileServices) : super('maquinas');
  AdminMaquinaController.fromConnection(Connection conn)
      : super.fromConnection('maquinas', conn);

  @mvc.ViewController('/agregar', methods: const [app.GET])
  agregarForm() async {
    return {};
  }

  @mvc.Controller('/agregar',
      methods: const [app.POST], allowMultipartRequest: true)
  Future<String> agregar(@app.Body(app.FORM) QueryMap form) async {
    Maquina maquina = decode(form, Maquina);
    maquina.id = new uuid.Uuid().v1();

    processForm(form);

    app.HttpBodyFileUpload file = form.archivosImagenes;
    if (file != null &&
        file is app.HttpBodyFileUpload &&
        file.content.length > 0) {
      var fileDb = await fileServices.newFile(file);
      maquina.imagenes = [fileDb];
    }

    await insertNow(maquina);

    return "/admin/maquinas/${maquina.id}";
  }

  @mvc.ViewController("/:id",
      filePath: '/admin/maquinas/agregar', methods: const [app.GET])
  Future<Maquina> getMaquina(String id) async {
    Maquina maquina = await getNow(id);

    if (maquina == null) throw new app.ErrorResponse(
        404, "La maquina no fue encontrada");

    return maquina;
  }

  @mvc.Controller("/:id",
      filePath: '/admin/maquinas/agregar',
      methods: const [app.POST],
      allowMultipartRequest: true)
  updateMaquina(String id, @app.Body(app.FORM) QueryMap form) async {
    print(form);
    processForm(form);
    Maquina maquina = decode(form, Maquina);
    RqlQuery query = updateTyped(id, maquina);



    app.HttpBodyFileUpload file = form.archivosImagenes;
    if (file != null &&
        file is app.HttpBodyFileUpload &&
        file.content.length > 0) {
      var fileDb = await fileServices.newFile(file);

      query = r.expr([
        query,
        get(id).update((RqlQuery maq) => {
          'imagenes': maq('imagenes').add([encode(fileDb)])
        })
      ]);
    }
    await query.run(conn);
    return "/admin/maquinas/$id";
  }

  @mvc.Controller('/:id/imagenes/:idImagen/eliminar',
      methods: const [app.DELETE])
  eliminarImagen(String id, String idImagen) async {
    await fileServices.deleteFile(idImagen);
    await fileServices.deleteMetadata(idImagen);

    await get(id)
        .update((RqlQuery maquina) => {
      'imagenes': maquina('imagenes')
          .filter((RqlQuery imagen) => imagen('id').eq(idImagen).not())
    })
        .run(conn);
  }

  @mvc.DefaultViewController(urlPosfix: '/todas', methods: const [app.GET])
  Future<List<Maquina>> viewTodas() async {
    Cursor result = await this.run(conn);
    List<Map> list = await result.toArray();
    return list.map((m) => decode(m, Maquina)).toList();
  }

  @mvc.Controller('/:id/eliminar', methods: const [app.DELETE])
  Future eliminar(String id) async {
    Maquina maquina = await getNow(id);

    if (maquina.imagenes != null) {
      for (var file in maquina.imagenes) {
        await eliminarImagen(id, file.id);
      }
    }

    await deleteNow(id);

    return '/admin/maquinas';
  }

  processForm (QueryMap form) {
    form.enEmail = form.enEmail == "true";
  }
}

@mvc.GroupController('/maquinas', root: '/web/html')
class MaquinaController extends RethinkServices<Maquina> {

  AdminMaquinaController adminMaquinaController;

  MaquinaController(this.adminMaquinaController) : super('maquinas');


}
