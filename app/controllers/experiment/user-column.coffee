UserColumnController = Ember.ObjectController.extend({
  needs: "experiment"

  timeFilteredVotes: Ember.computed.alias("controllers.experiment.timeFilteredVotes")

  scoresByParticipant: [],

  init: ->
    @get('timeFilteredVotes')

  actions: {
    buildChart: ->
      @get('votes').then( =>
        @get('participants').then ( =>
          @refreshChart()
        )
      )
  }

  calculateScoresByParticipant:( ->
    votes = @get('timeFilteredVotes')
    Promise.all(
      votes.mapBy('user')
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
  ).observes('timeFilteredVotes.[], participants.[]')


  scoreChanged:( ->
    @refreshChart()
  ).observes('scoresByParticipant')

  refreshChart: ->
    scores = @get('scoresByParticipant')
    participantIds = scores.map( (s) ->
      s.user.get('id')
    )

    container = $('.user-column svg')
    chartWidth = container.width()
    chartHeight = container.height()

    numCols = 5
    row = (i) ->
      Math.floor(i / numCols)

    col = (i) ->
      i % numCols

    numRows = row(scores.length - 1)

    colScale = d3.scale.ordinal()
      .domain([0...numCols])
      .rangeRoundBands([0, chartWidth], 0.5)

    rowScale = d3.scale.ordinal()
      .domain([0..numRows])
      .rangeRoundBands([0, chartHeight], 0.5)

    height = 100
    picHeight = 50

    scoreScale = d3.scale.linear()
      .domain([-10, 0, 10])
      .range([0, height, 0])
      .clamp(true)

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

    g = userGroups.transition()
    g.attr('transform', (d, i) ->
      "translate(#{colScale(col(i))}, #{rowScale(row(i))})"
    )
    r = g.select('rect')
    valRect(r)

    g = userGroups.enter()
      .append('g')

    g.classed('user-column-group', true)
      .attr('data-user-id', (d) ->
        d.user.get('id')
      )
      .attr('transform', (d, i) ->
        "translate(#{colScale(col(i))}, #{rowScale(row(i))})"
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
