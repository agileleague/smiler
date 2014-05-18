IndexRoute = Ember.Route.extend({
  model: ->
    experiments: [
      {name: "foo"},
      {name: "bar"}
    ]

})

`export default IndexRoute;`
