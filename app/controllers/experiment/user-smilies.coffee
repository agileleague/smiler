UserSmiliesController = Ember.ObjectController.extend({
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

    faceRadius = 50
    mouthXOffset = 20
    mouthYOffset = 20

    userScale = d3.scale.ordinal()
      .domain(participantIds)
      .rangeRoundBands([0, 600], 0.5)

    mouthControlScale = d3.scale.linear()
      .domain([-10, 10])
      .range([-faceRadius, faceRadius])

    mouthPointScale = d3.scale.linear()
      .domain([-10, 10])
      .range([mouthYOffset * 2, 0])

    userGroups = d3.select('.user-smilies svg').selectAll('g.user-smiley-group').data(scores, (d) ->
      d.user.get('id')
    )

    mouthPath = (datum) ->
      start = [mouthXOffset - faceRadius, mouthPointScale(datum.score)]
      finish = [faceRadius - mouthXOffset, mouthPointScale(datum.score)]
      control = [0, mouthControlScale(datum.score)]

      "M#{start[0]},#{start[1]} Q#{control[0]},#{control[1]} #{finish[0]},#{finish[1]}"

    # Update
    g = userGroups.transition()
      .attr('data-score', (d) ->
        d.score
      )

    mouth = g.select('path.mouth')
      .attr('d', (d) ->
        mouthPath(d)
      )

    # Create
    g = userGroups.enter()
      .append('g')

    g.classed('user-smiley-group', true)
      .attr('data-user-id', (d) ->
        d.user.get('id')
      )
      .attr('data-score', (d) ->
        d.score
      )
      .attr('transform', (d) ->
        "translate(#{userScale(d.user.get('id'))},80)"
      )

    g.append('circle')
      .classed('face-outer-circle', true)
      .attr('r', faceRadius)


    mouth = g.append('path')
      .classed('mouth', true)
      .attr('d', (d) ->
        mouthPath(d)
      )


})

`export default UserSmiliesController;`
