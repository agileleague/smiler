User = DS.Model.extend({
  username: DS.attr(),
  displayName: DS.attr(),
  avatarUrl: DS.attr(),
  provider: DS.attr(),
  isModerator: DS.attr()
})

`export default User;`
