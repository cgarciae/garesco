part of garesco.email;

class User {
  @Field() String id;
  @Field() String email;
  @Field() String password;
  @Field() List<String> roles;
}