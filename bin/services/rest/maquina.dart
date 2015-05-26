part of garesco.email.server;

@mvc.GroupController('/maquinas', root: '/lib/views')
class MaquinaServices extends RethinkServices<Maquina> {

  MaquinaServices() : super('maquinas');
  MaquinaServices.fromConnection (Connection conn) : super.fromConnection('maquinas', conn);

  @mvc.DataController('/agregar', methods: const [app.POST])
  Future<Maquina> agregar(@Decode() Maquina maquina) async {
    maquina.id = new uuid.Uuid().v1();
    await insertNow(maquina);
    return maquina;
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

  @mvc.DataController('/:id')
  Future<Maquina> obtener(String id) => getNow(id);

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
