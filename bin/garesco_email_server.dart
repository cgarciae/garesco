library garesco.email.server;

import 'package:redstone_mapper_mongo/service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:redstone_utilities/redstone_utilities.dart';
import 'package:redstone_mvc/redstone_mvc.dart' as mvc;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:quiver/iterables.dart' as qi;
import 'package:garesco_email/garesco_email.dart';
import 'dart:async';

part 'services/rest/maquina.dart';
part 'services/rest/categoria.dart';
part 'services/rest/email.dart';