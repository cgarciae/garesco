library garesco.email.server;

import 'package:mustache/mustache.dart';
import 'package:redstone/server.dart' as app;
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone/query_map.dart';
import 'package:redstone_utilities/redstone_utilities.dart';
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
import 'package:logging/logging.dart';

part 'services/mvc/maquina.dart';
part 'services/mvc/categoria.dart';
part 'services/mvc/email.dart';
part 'services/general/file_services.dart';
part 'services/general/generic_rethink_services.dart';

main() async {
  //var dbManager = new MongoDbManager('mongodb://192.168.59.103:8095/garesco_email', poolSize: 3);

  var config = new ConfigRethink(
    host: "192.168.59.103",
    tables: [
      new TableConfig(Col.maquinas),
      new TableConfig(Col.files)
    ]
  );
  await setupRethink(config);

  var dbManager = new RethinkDbManager.fromCongif(config);

  app.addPlugin(getMapperPlugin(dbManager));
  app.addPlugin(mvc.mvcPluggin);
  app.addPlugin(securityPlugin);

  app.setShelfHandler(createStaticHandler(
    staticFolder,
    defaultDocument: "index.html",
    serveFilesOutsidePath: true));

  app.addModule(new Module()
    ..bind(FileServices)
    ..bind(AdminMaquinaServices)
    ..bind(InjectableRethinkConnection));

  mvc.config = new mvc.MvcConfig();

  app.setupConsoleLog(Level.ALL);
  app.start(port: 9090);
}

@mvc.GroupController('/email', root: '/lib/views')
class TestEmail {
  @mvc.ViewController('/render', methods: const [app.POST])
  Email render(@Decode() Email email) => email;

  @mvc.DataController('/json', methods: const [app.POST])
  json(@Decode() Email email) => email;

  @mvc.DataController('/form', methods: const [app.POST], allowMultipartRequest: true)
  testForm(@Decode(from: const [app.FORM]) Email m) {
    print(m.urlBanner);
    return m;
  }

  @Secure (level: 0)
  @app.Route ('test')
  test () => "test";
}


