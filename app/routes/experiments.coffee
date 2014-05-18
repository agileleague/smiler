ExperimentsRoute = Ember.Route.extend({
  model: ->
    @store.findAll('experiment')
})

`export default ExperimentsRoute;`

