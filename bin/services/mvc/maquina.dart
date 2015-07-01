part of garesco.email.server;

@mvc.GroupController('/admin/maquinas')
class AdminMaquinaController extends RethinkServices<Maquina> {
  FileServices fileServices;

  AdminMaquinaController(this.fileServices) : super('maquinas');
  AdminMaquinaController.fromConnection(Connection conn)
      : super.fromConnection('maquinas', conn);

  @mvc.ViewController('/agregar',
      localPath: '/maquina', methods: const [app.GET])
  agregarForm() async {
    return {};
  }

  @mvc.Controller('/agregar',
      localPath: '/maquina',
      methods: const [app.POST],
      allowMultipartRequest: true)
  Future<shelf.Response> agregar(@app.Body(app.FORM) DynamicMap form) async {
    processForm(form);
    Maquina maquina = decode(form, Maquina);
    maquina.id = new uuid.Uuid().v1();

    HttpBodyFileUpload file = form.archivosImagenes;
    if (file != null && file is HttpBodyFileUpload && file.content.length > 0) {
      var fileDb = await fileServices.newFile(file);
      maquina.imagenes = [fileDb];
    }

    await insertNow(maquina);

    return app.redirect("/admin/maquinas/${maquina.id}");
  }

  @mvc.ViewController("/:id",
      localPath: '/maquina',
      methods: const [app.GET],
      allowMultipartRequest: true)
  Future<Maquina> getMaquina(String id) async {
    Maquina maquina = await getNow(id);

    if (maquina == null) throw new app.ErrorResponse(
        404, "La maquina no fue encontrada");

    return maquina;
  }

  @mvc.Controller("/:id",
      localPath: '/maquina',
      methods: const [app.POST],
      allowMultipartRequest: true)
  updateMaquina(String id, @app.Body(app.FORM) DynamicMap form) async {
    processForm(form);
    Maquina maquina = decode(form, Maquina);
    RqlQuery query = updateTyped(id, maquina);

    HttpBodyFileUpload file = form.archivosImagenes;
    if (file != null && file is HttpBodyFileUpload && file.content.length > 0) {
      var fileDb = await fileServices.newFile(file);
      var imagenes = 'imagenes';

      query = r.expr([
        query,
        get(id).update((Var maq) =>
        //if
        r.branch(maq.hasFields(imagenes),
        //then
        {imagenes: maq(imagenes).add([encode(fileDb)])},
        //else
        {imagenes: [encode(fileDb)]}
        ))
      ]);
    }
    var resp = await query.run(conn);

    return app.redirect("/admin/maquinas/$id");
  }

  @mvc.Controller('/:id/imagenes/:idImagen/eliminar', methods: const [app.GET])
  eliminarImagen(String id, String idImagen) async {
    await fileServices.deleteFile(idImagen);
    await fileServices.deleteMetadata(idImagen);

    await get(id)
        .update((RqlQuery maquina) => {
      'imagenes': maquina('imagenes')
          .filter((RqlQuery imagen) => imagen('id').eq(idImagen).not())
    })
        .run(conn);

    return app.redirect('/admin/maquinas/$id');
  }

  @mvc.DefaultViewController(subpath: '/todas', methods: const [app.GET])
  Future<List<Maquina>> viewTodas() async {
    Cursor result = await this.run(conn);
    List<Map> list = await result.toArray();
    return list.map((m) => decode(m, Maquina)).toList();
  }

  @mvc.Controller('/:id/eliminar', methods: const [app.POST, app.DELETE])
  Future eliminar(String id) async {
    Maquina maquina = await getNow(id);

    if (maquina.imagenes != null) {
      for (var file in maquina.imagenes) {
        await eliminarImagen(id, file.id);
      }
    }

    await deleteNow(id);
    return app.redirect('/admin/maquinas');
  }

  processForm(DynamicMap form) {
    form.enEmail = form.enEmail == "true";
  }
}

@mvc.GroupController('/maquinas')
class MaquinaController extends RethinkServices<Maquina> {
  AdminMaquinaController adminMaquinaController;

  MaquinaController(this.adminMaquinaController) : super('maquinas');

  @mvc.DefaultViewController(subpath: '/todas')
  maquinas() => adminMaquinaController.viewTodas();

  @mvc.ViewController('/:id', localPath: '/maquina')
  getMaquina(String id) => adminMaquinaController.getMaquina(id);
}
