part of garesco.email.server;

@Roles(const ['admin'], failureRedirect: '/users/login')
@mvc.GroupController('/admin/maquinas')
class AdminMaquinaController extends RethinkServices<Maquina> {
  FileServices fileServices;

  AdminMaquinaController(this.fileServices, InjectableRethinkConnection conn)
      : super.fromInjectableConnection('maquinas', conn);
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
    maquina.imagenes = [];
    maquina.id = new uuid.Uuid().v1();

    var files = form.values.where((file) => file is HttpBodyFileUpload && file.content.length > 0);
    for (var file in files) {
      var fileDb = await fileServices.newFile(file);
      maquina.imagenes.add(fileDb);
    }

    await insertNow(maquina);

    return new shelf.Response.ok("/admin/maquinas/${maquina.id}");
  }

  @mvc.ViewController("/:id",
      localPath: '/maquina',
      methods: const [app.GET])
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

    var files = form.values.where((file) => file is HttpBodyFileUpload && file.content.length > 0);
    for (var file in files) {

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
                {imagenes: [encode(fileDb)]}))
      ]);
    }
    var resp = await query.run(conn);

    return new shelf.Response.ok("/admin/maquinas/$id");
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
  Future<Map> viewTodas({@app.QueryParam() String eti,
      @app.QueryParam() String modelo, @app.QueryParam() String pais}) async {

    Cursor result = await filter((Var maquina) {
      RqlQuery cond = r.expr(true);
      if (eti != null && eti != '') {
        cond = cond.and(maquina('eti').match(eti));
      }
      if (modelo != null && modelo != '') {
        cond = cond.and(maquina('modelo').match(modelo));
      }
      if (pais != null && pais != '') {
        cond = cond.and(maquina('pais').match(pais));
      }
      return cond;
    }).run(conn);

    List<Map> list = await result.toArray();

    return {
      'eti': eti,
      'modelo': modelo,
      'pais': pais,
      'maquinas': list.map((m) => decode(m, Maquina)).toList()
    };
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

  @mvc.Controller('/limpiar-email')
  limpiarEmail() async {
    await update({'enEmail': false}).run(conn);
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
  maquinas({@app.QueryParam() String eti, @app.QueryParam() String modelo,
          @app.QueryParam() String pais}) =>
      adminMaquinaController.viewTodas(eti: eti, pais: pais, modelo: modelo);

  @mvc.ViewController('/:id', localPath: '/maquina')
  getMaquina(String id) => adminMaquinaController.getMaquina(id);
}
