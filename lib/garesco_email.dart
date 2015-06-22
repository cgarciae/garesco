library garesco.email;

import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/src/dynamic_map.dart';
import 'package:quiver/iterables.dart' as qi;

part 'models/clases.dart';

const int tipoBuild = TipoBuild.desarrollo;

int get port => 9090;

String get staticFolder {
  switch (tipoBuild)
  {
    case TipoBuild.desarrollo:
      return "web";
    case TipoBuild.jsTesting:
      return "build/web";
    case TipoBuild.dockerTesting:
    case TipoBuild.deploy:
      return "build/web";
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
      return "104.131.109.228";
  }
}



String get localHost => "http://${partialHost}/";

String get partialDBHost {
  switch (tipoBuild)
  {
    case TipoBuild.desarrollo:
    case TipoBuild.jsTesting:
      return "192.168.59.103:8095";
    case TipoBuild.dockerTesting:
    case TipoBuild.deploy:
      return "db";
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
}

QueryMap queryMap (Map map) => new QueryMap (map);