part of garesco.email.server;

/*
@mvc.GroupController('/categorias')
class CategoriaServices extends MongoService<Categoria> {
  CategoriaServices(MongoConnection connection) : super('categorias', connection);

  @mvc.DataController('/agregar', methods: const [app.POST])
  Future<Categoria> agregar(@Decode() Categoria maquina) async {
    maquina.id = new ObjectId().toHexString();
    await NewGeneric(maquina);
    return maquina;
  }

  @mvc.DataController('/nueva', methods: const [app.POST])
  Future<Categoria> nueva() => agregar(new Categoria()
    ..urlIcono = ""
    ..heading = ""
    ..descripcion = ""
    ..link = "");

  @mvc.DataController('/:id')
  Future<Categoria> obtener(String id) => GetGeneric(id);

  @mvc.DataController('/:id', methods: const [app.PUT])
  Future<Categoria> actualizar(String id, @Decode() Categoria maquina) async {
    maquina.id = null;
    await UpdateGeneric(id, maquina);
    return obtener(id);
  }

  @mvc.DataController('/:id', methods: const [app.DELETE])
  Future<Ref> eliminar(String id) => DeleteGeneric(id);

  @mvc.DataController('/todas')
  Future<List<Categoria>> todas() => find();
}
*/