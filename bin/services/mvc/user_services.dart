part of garesco.email.server;

@mvc.GroupController('/users')
class UserServices extends RethinkServices<User>  {
  UserServices(InjectableRethinkConnection injectableConnection)
      : super.fromInjectableConnection('users', injectableConnection);

  Future<Map> addUser (User user) async {
    return insertNow(user);
  }

  @mvc.Controller('/logout')
  logout() => app.redirect('/users/login').change(headers: {'Set-Cookie': 'id=deleted; roles=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT;'});

  @mvc.ViewController('/login')
  loginForm() => {};

  @mvc.Controller('/login', methods: const[app.POST])
  login (@Decode(from: const[app.FORM]) User user) async {
    User foundUser = await this.findOne((Var user_) => user_('email').eq(user.email).and(user_('password').eq(user.password)));

    if (foundUser == null)
      return "USER NOT FOUND";

    var roles = foundUser.roles.reduce((a, b) => '$a,$b');
    var idCookie = new ck.Cookie('id', foundUser.id);

    return app.redirect('/admin/maquinas')
      .change(headers: {'Set-Cookie': idCookie.toString()});
  }

  @mvc.Controller('/has-roles')
  Future<bool> hasRoles(@Header("authorization") String id, @Cookie() List<String> roles) async {
    var user = get(id);

    var query = r.branch(user.hasFields("roles"),
        user('roles').contains((role) => r.expr(["b", "c"]).contains(role)),
        false);

    bool result = await query.run(conn);

    print(result);

    return result;
  }
}
