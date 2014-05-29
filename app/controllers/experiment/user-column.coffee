UserColumnController = Ember.ObjectController.extend({
  needs: "experiment"

  scoresByParticipant: [],

  actions: {
    buildChart: ->
      @get('votes').then( =>
        @get('participants').then ( =>
          @refreshChart()
        )
      )
  }

  calculateScoresByParticipant:( ->
    votes = null
    @get('votes').then( (vs) =>
      votes = vs
      Promise.all(
        votes.mapBy('user')
      )
    ).then( =>
      @get('participants')
    ).then( (users) =>
      scores = []
      users.map( (u) =>
        score = votes.filterBy('user.id', u.get('id')).map( (v) =>
          v.get('score')
        ).reduce( (x,y) ->
          x + y
        , 0)

        scores.push({ user: u, score: score })
      )

      console.log("Scores:")
      console.log(scores)
      @set('scoresByParticipant', scores)
    )
  ).observes('votes.[], participants.[]')


  scoreChanged:( ->
    @refreshChart()
  ).observes('scoresByParticipant')

  refreshChart: ->
    scores = @get('scoresByParticipant')
    participantIds = scores.map( (s) ->
      s.user.get('id')
    )

    height = 100
    picHeight = 50

    userScale = d3.scale.ordinal()
      .domain([participantIds])
      .rangeRoundBands([0, 600], 0.5)

    scoreScale = d3.scale.linear()
      .domain([-10, 0, 10])
      .range([0, height, 0])

    userGroups = d3.select('.user-column svg').selectAll('g').data(scores, (d) ->
      d.user.get('id')
    )

    classRect = (rect) ->
      rect.attr('class', (d) ->
        "score-#{d.score}"
      )
      .classed('negative-score', (d) ->
        d.score < 0
      )
      .classed('positive-score', (d) ->
        d.score > 0
      )
      .classed('zero-score', (d) ->
        d.score == 0
      )

    valRect = (rect) ->
      rect.attr('y', (d) ->
        scoreScale(d.score)
      )
      .attr('height', (d) ->
        height - scoreScale(d.score)
      )
      .attr('transform', (d) ->
        if d.score > 0
          "translate(0,0)"
        else
          # Draw it upwards, then shift it down below the picture
          "translate(0,#{picHeight + (height - scoreScale(d.score))})"
      )

    r = userGroups.select('rect')
    classRect(r)

    r = userGroups.transition().select('rect')
    valRect(r)

    g = userGroups.enter()
      .append('g')

    g.classed('user-column-group', true)
      .attr('data-user-id', (d) ->
        d.user.get('id')
      )
      .attr('transform', (d) ->
        "translate(#{userScale(d.user.get('id'))},0)"
      )

    r = g.append('rect')
    classRect(r)
    valRect(r)
      .attr('width', 10)

    g.append('image')
      .attr('x', -20)
      .attr('y', height)
      .attr('xlink:href', (d) ->
        d.user.get('avatarUrl')
      )
      .attr('width', picHeight)
      .attr('height', picHeight)



})

`export default UserColumnController;`
