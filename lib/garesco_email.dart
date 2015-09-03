library garesco.email;

import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/src/dynamic_map.dart';
import 'package:quiver/iterables.dart' as qi;
import 'package:path/path.dart' as path;

part 'models/clases.dart';
part 'models/user.dart';

const int tipoBuild = TipoBuild.deploy;

int get port => 9090;

String get staticFolder {
  switch (tipoBuild)
  {
    case TipoBuild.desarrollo:
    case TipoBuild.jsTesting:
    case TipoBuild.dockerTesting:
    case TipoBuild.deploy:
      return "web";
  }
}

String get filesPath {
  switch (tipoBuild)
  {
    case TipoBuild.desarrollo:
    case TipoBuild.jsTesting:
      return '${path.current}/files';
    case TipoBuild.dockerTesting:
    case TipoBuild.deploy:
      return "/data/files";
  }
}

String get partialHost {
  switch (tipoBuild)
  {
    case TipoBuild.desarrollo:
    case TipoBuild.jsTesting:
      return "localhost:9090";
    case TipoBuild.dockerTesting:
      return "192.168.59.103:9090";
    case TipoBuild.deploy:
      return "45.55.88.247";
  }
}



String get localHost => "http://${partialHost}/";

String get partialDBHost {
  switch (tipoBuild)
  {
    case TipoBuild.desarrollo:
    case TipoBuild.jsTesting:
      return "192.168.99.100";
    case TipoBuild.dockerTesting:
    case TipoBuild.deploy:
      return "rethinkdb";
  }
}

class TipoBuild
{
  static const int desarrollo =  0;
  static const int jsTesting =  1;
  static const int dockerTesting =  2;
  static const int deploy =  3;
}

class Col {
  static const String files = 'files';
  static const String maquinas = 'maquinas';
  static const String users = 'users';
}

DynamicMap queryMap (Map map) => new DynamicMap (map);