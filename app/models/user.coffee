User = DS.Model.extend({
  username: DS.attr(),
  email: DS.attr(),
  displayName: DS.attr(),
  avatarUrl: DS.attr()
})

`export default User;`
