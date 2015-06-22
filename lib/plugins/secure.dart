import 'package:redstone/redstone.dart' as app;

class Secure {
  final int level;
  const Secure ({this.level: 0});
}

void securityPlugin(app.Manager manager) {
  //Controller Group
  manager.addRouteWrapper(Secure, (metadata, injector, app.Request request, route) async {

    var group = metadata as Secure;

    return route(injector, request);

  }, includeGroups: true);
}