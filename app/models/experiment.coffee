Experiment = DS.Model.extend({
  name: DS.attr(),
  participants: DS.hasMany('user', { async: true })
})

`export default Experiment;`
