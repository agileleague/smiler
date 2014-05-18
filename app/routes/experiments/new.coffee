ExperimentsNewRoute = Ember.Route.extend({
  model: ->
    @store.createRecord('experiment')

  actions: {
    save: ->
      @currentModel.save().then( =>
        @transitionTo('experiments')
      )
  }

})

`export default ExperimentsNewRoute;`
