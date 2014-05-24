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

    refreshChart = =>
      timeNow = (new Date().getTime() / 1000)
      timeMin = timeNow - (30)

      timeScale = d3.scale.linear()
        .domain([timeMin, timeNow])
        .range([0, 600])

      voteGs = d3.select('.simple-time-dots svg').selectAll('g').data(@get('votes').toArray(), (d) ->
        d.get('id')
      )

      g = voteGs.enter()
        .append('g')

      g.attr('class', 'vote-dot')
        .attr('data-vote-id', (d) ->
          d.get('id')
        )

      c = g.append('circle')
        .classed('upvote', (d) ->
          d.get('score') > 0
        )
        .classed('downvote', (d) ->
          d.get('score') < 0
        )
        .attr('cx', (d) ->
          timeScale(d.get('createdAt'))
        )
        .attr('cy', 40)
        .attr('r', 7)

      voteGs.transition().selectAll('circle')
        .attr('cx', (d) ->
          timeScale(d.get('createdAt'))
          )

      voteGs.exit()
        .remove()

      Ember.run.later( ->
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

