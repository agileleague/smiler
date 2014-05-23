Experiment = DS.Model.extend({
  name: DS.attr(),
  participants: DS.hasMany('user', { async: true }),
  votes: DS.hasMany('vote', { async: true })
})

`export default Experiment;`
