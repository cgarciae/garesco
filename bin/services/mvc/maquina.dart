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
    Maquina maquina = await getNow(id);

    print("GET");

    if (maquina == null)
      throw new app.ErrorResponse(404, "La maquina no fue encontrada");

    return maquina;
  }

  @mvc.ViewController("/:id", filePath: '/admin/maquinas/agregar',
      methods: const [app.POST], allowMultipartRequest: true)
  updateMaquina(String id, @app.Body(app.FORM) QueryMap form) async {

    print("POST");

    Maquina maquina = decode(form, Maquina);
    RqlQuery query = updateTyped(id, maquina);



    if (form.archivosImagenes != null) {
      List<app.HttpBodyFileUpload> images = form.archivosImagenes is List
      ? form.archivosImagenes
      : [form.archivosImagenes];

      var imagenes = new List<FileDb>();
      for (var file in images) {
        FileDb fileDb = await fileServices.newFile(file);
        imagenes.add(fileDb);
      }

      query = r.expr([query,
        get(id).update((RqlQuery maq) => {
          'imagenes': maq('imagenes').add(encode(imagenes))
        })
      ]);
    }

    await query.run(conn);

    app.redirect("/admin/maquinas/$id");
  }

  @app.Route('/:id/imagenes/:idImagen/eliminar', methods: const [app.GET])
  eliminarImagen (String id, String idImagen) async {
    app.redirect("/admin/maquinas/$id");

    await fileServices.deleteFile(idImagen);
    await fileServices.deleteMetadata(idImagen);

    get(id).update((RqlQuery maquina) => {
      'imagenes': maquina('imagenes').filter((RqlQuery imagen) =>
        imagen('id').eq(idImagen).not()
      )
    })
    .run(conn);
  }

  @mvc.DefaultViewController (urlPosfix: '/todas',methods: const [app.GET])
  Future<List<Maquina>> viewTodas () async {
    print("TODAS");
    Cursor result = await this.run(conn);
    List<Map> list = await result.toArray();
    return list.map((m) => decode(m, Maquina)).toList();
  }


  @app.Route('/:id/eliminar', methods: const [app.POST])
  Future eliminar(String id) async {


    Maquina maquina = await getNow(id);
    print("ACA $id");

    if (maquina.imagenes != null) {
      for (var file in maquina.imagenes) {
        await eliminarImagen(id, file.id);
      }
    }

    await deleteNow(id);

    print("22222 $id");
    app.chain.("/admin/maquinas");
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
}
