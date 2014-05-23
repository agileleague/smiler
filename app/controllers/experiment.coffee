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

  votesChanged:( ->
    voteTimes = @get('votes').toArray().map( (v) ->
      v.get('createdAt')
    )

    height = 200
    scoreMax = 10
    scoreMin = -10

    refreshChart = =>
      timeNow = (new Date().getTime() / 1000)
      timeMin = timeNow - (30)

      timeScale = d3.scale.linear()
        .domain([timeMin, timeNow])
        .range([0, 600])

      scoreScale = d3.scale.linear()
        .domain([scoreMin, scoreMax])
        .range([height, 0])

      score = @get('totalScore')
      score = Math.min(score, scoreMax)
      score = Math.max(score, scoreMin)

      voteGs = d3.select('#up-down-bars svg').selectAll('g').data(@get('votes').toArray(), (d) ->
        d.get('id')
      )

      g = voteGs.enter()
        .append('g')

      g.attr('class', 'vote-dot')
        .attr('data-vote-id', (d) ->
          d.get('id')
        )

      c = g.append('circle')
        .attr('class', (d) ->
          if d.get('score') > 0 then 'upvote' else 'downvote'
        )
        .attr('cx', (d) ->
          timeScale(d.get('createdAt'))
        )
        .attr('cy', scoreScale(score))
        .attr('r', 7)

      voteGs.transition().selectAll('circle')
        .attr('cx', (d) ->
          timeScale(d.get('createdAt'))
          )

      voteGs.exit()
        .remove()

      Ember.run.later( ->
        console.log("refreshing")
        refreshChart()
      , 100)

    refreshChart()


  ).observes('votes.[]')

  actions: {
    joinExperiment: ->
      @get('participants').pushObject(@get('currentUser'))
      @get('model').save()

    upVote: ->
      @send('vote', 1)

    downVote: ->
      @send('vote', -1)

    vote: (score) ->
      v = @store.createRecord('vote', {
        user: @get('currentUser'),
        experiment: @get('model'),
        score: score
      })
      v.save()

      @get('votes').pushObject(v)
      @get('model').save()


  }

})

`export default ExperimentController;`

