ExperimentController = Ember.ObjectController.extend({
  needs: "authentication"

  currentUser: Ember.computed.alias("controllers.authentication.currentUser")

  isModerator: Ember.computed.alias("currentUser.isModerator")

  historyLengthInS: 300

  refreshHandle: null

  init: ->
    hook = Ember.run.later( =>
      @send('refilterVotes')
    , 100)

    @set('refreshHandle', hook)

  isParticipant:( ->
    if currentUser = @get('currentUser')
      u = @get('participants').findBy('id', currentUser.get('id'))
      if u then true else false
    else
      false
  ).property('participants.[]', 'currentUser')

  totalVotes:( ->
    @get('votes').toArray().length
  ).property('votes.[]')

  totalScore:( ->
    @get('votes').toArray().map( (v) ->
      v.get('score')
    ).reduce( (x,y) ->
      x + y
    , 0
    )
  ).property('votes.[]')

  timeFilteredVotes:( ->
    timeMin = if @get('historyLengthInS') > 0
      moment().subtract('seconds', @get('historyLengthInS'))
    else
      # Lifetime
      moment(0)

    @get('votes').toArray().filter( (vote) ->
      parseInt(vote.get('createdAt')) > timeMin.unix()
    )
  ).property('votes.[]', 'historyLengthInS')

  actions: {
    joinExperiment: ->
      @get('participants').then( =>
        @get('participants').pushObject(@get('currentUser'))
        @get('model').save()
      )

    upVote: ->
      @send('vote', 1)

    downVote: ->
      @send('vote', -1)

    vote: (score) ->
      unless @get('isParticipant')
        @send('joinExperiment')

      v = @store.createRecord('vote', {
        user: @get('currentUser'),
        experiment: @get('model'),
        score: score
      })
      v.save()

      @get('votes').pushObject(v)
      @get('model').save()

    setHistoryLength: (length) ->
      @set('historyLengthInS', length)
      @send('refilterVotes')

    refilterVotes: ->
      if @get('refreshHandle')
        Ember.run.cancel(@get('refreshHandle'))

      @set('refreshHandle', null)

      @notifyPropertyChange('timeFilteredVotes')

      hook = Ember.run.later( =>
        @send('refilterVotes')
      , 500)

      @set('refreshHandle', hook)
  }

})

`export default ExperimentController;`

