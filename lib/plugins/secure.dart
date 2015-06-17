import 'package:redstone/server.dart' as app;

class Secure {
  final int level;
  const Secure ({this.level: 0});
}

void securityPlugin(app.Manager manager) {
  //Controller Group
  manager.addRouteWrapper(Secure, (metadata, Map<String, String> pathSegments, injector, app.Request request, route) async {

    var group = metadata as Secure;

    //Give it an improbable name
    print(request.queryParams);

    return route(pathSegments, injector, request);

  }, includeGroups: true);
}