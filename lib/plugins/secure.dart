import 'package:redstone/redstone.dart' as app;
import 'dart:mirrors';
import 'package:di/di.dart';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'package:cookies/cookies.dart' as ck;
import 'package:redstone_mapper/mapper.dart';

class Roles {
  final List<String> roles;
  final String failureRedirect;
  const Roles (this.roles, {this.failureRedirect});
}

class Header {
  final String header;
  const Header ([this.header]);
}

class Cookie {
  final String key;
  const Cookie ([this.key]);
}

void securityPlugin(app.Manager manager) {
  //Controller Group
  manager.addRouteWrapper(Roles, (Roles metadata, injector, app.Request request, route) async {

    try {
      List<String> roles = [];
      try {
        var r = new Rethinkdb();
        var id = new ck.CookieJar(request.headers.cookie)['id'].value;
        var conn = app.request.attributes.dbConn.conn;
        roles = await r.table('users').get(id).getField('roles').run(conn);
      }
      catch (e) {}

      if (metadata.roles.any((role) => roles.contains(role)))
        return route(injector, request);
      else if (metadata.failureRedirect != null)
        return app.redirect(metadata.failureRedirect);
      else
        return "AUTHORIZATION ERROR: You don't have permission to access this resource.";
    }
    catch (e,s) {
      return "SERVER ERROR: $e\n$s";
    }

  }, includeGroups: true);
}

headersPlugin(app.Manager manager) {
  manager.addParameterProvider(Header, (Header metadata, Type type, String handlerName, String paramName, app.Request req, Injector injector) {
    var header = metadata.header != null? metadata.header: paramName;
    return req.headers[header];
  });
}

cookiesPlugin(app.Manager manager) {
  manager.addParameterProvider(Cookie, (Cookie metadata, Type type, String handlerName, String paramName, app.Request req, Injector injector) {
    var key = metadata.key != null? metadata.key: paramName;
    var cookies = new ck.CookieJar(req.headers.cookie);
    return type == ck.Cookie? cookies[key]: new List<String>().runtimeType.toString() == type.toString()? cookies[key].value.split(','): cookies[key].value;
  });
}