ExperimentController = Ember.ObjectController.extend({
  needs: "authentication",

  currentUser: Ember.computed.alias("controllers.authentication.currentUser"),

  isModerator: Ember.computed.alias("currentUser.isModerator")

  isParticipant:( ->
    if currentUser = @get('currentUser')
      u = @get('participants').findBy('id', currentUser.get('id'))
      if u then true else false
    else
      false
  ).property('participants.[]', 'currentUser')

  totalScore:( ->
    @get('votes').toArray().map( (v) ->
      v.get('score')
    ).reduce( (x,y) ->
      x + y
    , 0
    )
  ).property('votes.[]')

  actions: {
    joinExperiment: ->
      @get('participants').pushObject(@get('currentUser'))
      @get('model').save()

    upVote: ->
      v = @store.createRecord('vote', {
        user: @get('currentUser'),
        experiment: @get('model'),
        score: 1
      })
      v.save()

      @get('votes').pushObject(v)
      @get('model').save()
  }

})

`export default ExperimentController;`

