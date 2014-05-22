ExperimentController = Ember.ObjectController.extend({
  needs: "authentication",

  currentUser: Ember.computed.alias("controllers.authentication.currentUser"),

  isModerator: Ember.computed.alias("currentUser.isModerator")

  isParticipant:( ->
    if currentUser = @get('currentUser')
      u = @get('model.participants').findBy('id', currentUser.get('id'))
      if u then true else false
    else
      false
  ).property('model.participants', 'currentUser')

  actions: {
    joinExperiment: ->
      @get('model.participants').pushObject(@get('currentUser'))
      @get('model').save()
  }

})

`export default ExperimentController;`

