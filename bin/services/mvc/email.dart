part of garesco.email.server;
/*
@mvc.GroupController('/emails')
class EmailServices extends MongoService<Email> {
  EmailServices(MongoConnection connection) : super('emails', connection);

  @mvc.DataController('/agregar', methods: const [app.POST])
  Future<Email> agregar(@Decode() Email email) async {
    email.id = new ObjectId().toHexString();
    await NewGeneric(email);
    return email;
  }

  @mvc.DataController('/nuevo', methods: const [app.POST])
  Future<Email> nuevo() => agregar (new Email()
    ..categorias = []
    ..descripcionBottom = ""
    ..descripcionTop = ""
    ..headingBottom = ""
    ..headingTop = ""
    ..maquinas = []
    ..mensajeFinal = ""
    ..urlBanner = ""
    ..urlImagenFinal = "");

  @mvc.DataController('/:id')
  Future<Email> obtener(String id, {@app.QueryParam() bool export}) async {
    Email email = await GetGeneric(id);

    if (export == true) {
      var idsMaquina = email.maquinas.map((m) => stringToId(m.id)).toList();
      email.maquinas = await mongoDb.find(
          'maquinas', Maquina, where.oneFrom('_id', idsMaquina));

      var idsCategoria = email.categorias.map((c) => stringToId(c.id)).toList();
      email.categorias = await mongoDb.find(
          'categorias', Categoria, where.oneFrom('_id', idsCategoria));
    }

    return email;
  }

  @mvc.DataController('/:id', methods: const [app.PUT])
  Future<Email> actualizar(String id, @Decode() Email email) async {
    email.id = null;
    await UpdateGeneric(id, email);
    return obtener(id);
  }

  @mvc.DataController('/:id', methods: const [app.DELETE])
  Future<Ref> eliminar(String id) => DeleteGeneric(id);

  @mvc.DataController('/todos')
  Future<List<Email>> todas() => find();

  @mvc.DataController('/:id/maquinas', methods: const [app.POST])
  Future<Email> agregarMaquina(
      String id, @app.QueryParam() String idMaquina) async {
    var maquina = new Maquina()..id = idMaquina;

    await mongoDb.update(collectionName, where.id(stringToId(id)),
        modify.push('maquinas', mongoDb.encode(maquina)));

    return obtener(id);
  }

  @mvc.DataController('/:id/maquinas', methods: const [app.DELETE])
  Future<Email> eliminarMaquina(
      String id, @app.QueryParam() String idMaquina) async {
    await mongoDb.update(collectionName, where.id(stringToId(id)), {
      r'$pull': {'maquinas': {'_id': stringToId(idMaquina)}}
    });

    return obtener(id);
  }

  @mvc.DataController('/:id/categorias', methods: const [app.POST])
  Future<Email> agregarCategoria(
      String id, @app.QueryParam() String idCategoria) async {
    var categoria = new Maquina()..id = idCategoria;

    await mongoDb.update(collectionName, where.id(stringToId(id)),
        modify.push('categorias', mongoDb.encode(categoria)));

    return obtener(id);
  }

  @mvc.DataController('/:id/categorias', methods: const [app.DELETE])
  Future<Email> eliminarCategoria(
      String id, @app.QueryParam() String idCategoria) async {
    await mongoDb.update(collectionName, where.id(stringToId(id)), {
      r'$pull': {'categorias': {'_id': stringToId(idCategoria)}}
    });

    return obtener(id);
  }

  @mvc.ViewController('/:id/render', filePath: '/lib/views/email/render')
  Future<Email> render(String id) => obtener(id, export: true);
}

@mvc.ViewController('/email', filePath: '/lib/views/email/render')
Email renderEmail (@Decode() Email email) => email;
*/
