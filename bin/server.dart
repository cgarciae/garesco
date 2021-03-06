library garesco.email.server;

import 'package:mustache/mustache.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone/src/dynamic_map.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:path/path.dart' as path;
import 'package:cookies/cookies.dart' as ck;
import 'package:redstone_mvc/redstone_mvc.dart' as mvc;
import 'package:di/di.dart';
import 'package:garesco_email/garesco_email.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:shelf_static/shelf_static.dart';
import 'dart:async';
import 'package:redstone_rethinkdb/redstone_rethinkdb.dart';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'package:garesco_email/plugins/secure.dart';
import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:http_server/src/http_body.dart';

part 'services/mvc/maquina.dart';
part 'services/mvc/categoria.dart';
part 'services/mvc/email.dart';
part 'services/mvc/user_services.dart';
part 'services/general/file_services.dart';
part 'services/general/generic_rethink_services.dart';

main() async {
  //var dbManager = new MongoDbManager('mongodb://192.168.59.103:8095/garesco_email', poolSize: 3);

  var config = new ConfigRethink(
      host: partialDBHost,
      tables: [new TableConfig(Col.maquinas), new TableConfig(Col.files), new TableConfig(Col.users)]);
  await setupRethink(config);

  var dbManager = new RethinkDbManager.fromCongif(config);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(mvc.mvcPluggin);
  app.addPlugin(securityPlugin);
  app.addPlugin(headersPlugin);
  app.addPlugin(cookiesPlugin);

  app.setShelfHandler(createStaticHandler(staticFolder,
      defaultDocument: "index.html", serveFilesOutsidePath: true));

  app.showErrorPage = false;

  mvc.config = new mvc.MvcConfig();

  app.addModule(new Module()
    ..bind(FileServices)
    ..bind(AdminMaquinaController)
    ..bind(InjectableRethinkConnection)
    ..bind(TestEmail)
    ..bind(UserServices));

  app.setupConsoleLog(Level.ALL);
  await app.start(port: 9090);

  //Crear folder "files" si no existe
  var files = new Directory(filesPath);
  if (!await files.exists()) {
    await files.create();
  }

  RethinkConnection conn = await dbManager.getConnection();
  var r = new Rethinkdb();

  var injector = new ModuleInjector([new Module()
    ..bind(FileServices)
    ..bind(AdminMaquinaController)
    ..bind(InjectableRethinkConnection, toValue: new InjectableRethinkConnection.fromConnection(conn.conn))
    ..bind(TestEmail)
    ..bind(UserServices)]);

  UserServices userServices = injector.get(UserServices);
  //Crear admin si no existe
  if ((await userServices.count().run(conn.conn)) == 0) {
    String id = await r.uuid().run(conn.conn);
    await userServices.addUser(new User()
      ..id = id
      ..password = "Garesco1234"
      ..email = "octavio@garesco.com"
      ..roles = ["admin"]);
  }

}

@mvc.Controller('/test-header')
testHeader (@Header("authorization") String id, @Cookie() List<String> roles) => id + roles.toString();

@mvc.Controller('/test-cookie')
testCookie (@Cookie() ck.Cookie id, @Cookie() List<String> roles) => id;

@mvc.Controller('/test-set-cookie')
testSetCookie () => app.response.change(headers: {'Set-Cookie': "id=2"});

@mvc.Controller('/test-set-roles')
testSetRoles () => app.response.change(headers: {'Set-Cookie': 'roles=admin,chao'});

@mvc.Controller('/test-del-roles')
testDelRoles () => app.response.change(headers: {'Set-Cookie': 'roles=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT'});

@mvc.Controller('/test-decode')
testDecode () => new List<String>().runtimeType is List;

@Roles(const ['admin'])
@app.Route('/test')
test() => "test";

@mvc.Controller('/login')
login() => "LOGIN";

@app.Interceptor(r'/.*')
handleResponseHeader() async {
  var headers = {"Access-Control-Allow-Origin": "*"};

  if (tipoBuild <= TipoBuild.jsTesting) {
    headers['Cache-Control'] =
        'private, no-store, no-cache, must-revalidate, max-age=0';
  }
  //process the chain and wrap the response
  await app.chain.next();

  return app.response.change(headers: headers);
}

@mvc.GroupController('/email')
class TestEmail extends RethinkServices {
  AdminMaquinaController maquinaServices;

  TestEmail(this.maquinaServices) : super('emails');

  @mvc.ViewController('/render', methods: const [app.POST])
  Email render(@Decode() Email email) => email;

  @mvc.ViewController('/render', methods: const [app.GET], ignoreMaster: true)
  Future<Email> autoRender() async {
    Cursor c = await maquinaServices
        .filter((RqlQuery m) => m('enEmail').eq(true))
        .run(conn);

    List<Maquina> maquinas = decode(await c.toArray(), Maquina);
    var email = (await staticEmail)..maquinas = maquinas;
    return email;
  }

  @mvc.DataController('/json', methods: const [app.POST])
  json(@Decode() Email email) => email;

  @mvc.DataController('/form',
      methods: const [app.POST], allowMultipartRequest: true)
  testForm(@Decode(from: const [app.FORM]) Email m) {
    print(m.urlBanner);
    return m;
  }


}

Future<Email> get staticEmail async {
  var json = await new File(path.current + '/bin/email.json').readAsString(
      encoding: LATIN1);
  return decodeJson(json, Email);
}
