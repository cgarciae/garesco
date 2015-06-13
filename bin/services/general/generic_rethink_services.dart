part of garesco.email.server;

class GenericRethinkServices<T extends Ref> extends RethinkServices<T> {
  GenericRethinkServices (String tableName, InjectableRethinkConnection irc): super.fromInjectableConnection (tableName, irc);

  Future<T> genericInsert (T record, {error: 'Error al insertar recurso'}) async {
    var resp = queryMap(await insertNow(record));
    if (resp.errors > 0)
      throw new app.ErrorResponse (400, {'error': '$error: ${resp.first_error}'});
    return record..id = resp.generated_keys.first;
  }

  Future<T> genericGet (String id, {error: 'Error al obtener el recurso'}) async {
    var record = await getNow(id);
    if (record == null)
      throw new app.ErrorResponse (400, {'error': error});
    return record;
  }

  Future genericUpdate (String id, T delta, {error: 'Error al actualizar el recurso'}) async {
    var resp = queryMap(await updateNow(id, delta));
    if (resp.errors > 0)
      throw new app.ErrorResponse (400, {'error': '$error: ${resp.first_error}'});
  }

  Future<Ref> genericDelete (String id, {error: 'Error al eliminar el recurso'}) async {
    var resp = await deleteNow(id);
    if (resp.errors > 0)
      throw new app.ErrorResponse (400, {'error': '$error: ${resp.first_error}'});
    return new Ref()..id = id;
  }

  Future<List<T>> genericAll ([expr = const {}]) async {
    Cursor cursor = await filter(expr).run(conn);
    return decode(await cursor.toArray(), T);
  }
}