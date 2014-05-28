Vote = DS.Model.extend({
  user: DS.belongsTo('user', { async: true }),
  experiment: DS.belongsTo('experiment', { async: true }),
  score: DS.attr('number'),
  createdAt: DS.attr('number', {
    defaultValue: ->
      Math.floor(new Date().getTime() / 1000)
  })
})

`export default Vote;`
