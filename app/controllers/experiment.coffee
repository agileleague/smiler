ExperimentController = Ember.Controller.extend({
  needs: "authentication",

  currentUser: Ember.computed.alias("controllers.authentication.currentUser"),

  participants: Ember.computed.alias("model.participants"),

  isParticipant:( ->
    if currentUser = @get('currentUser')
      u = @get('participants').findBy('id', currentUser.get('id'))
      if u then true else false
    else
      false
  ).property('participants', 'currentUser')

  actions: {
    joinExperiment: ->
      @get('participants').pushObject(@get('currentUser'))
      @get('model').save()
  }

})

`export default ExperimentController;`

