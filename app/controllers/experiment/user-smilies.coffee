UserSmiliesController = Ember.ObjectController.extend({
  needs: "experiment"

  scoresByParticipant: [],

  timeFilteredVotes: Ember.computed.alias("controllers.experiment.timeFilteredVotes")

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

    faceRadius = 50
    eyeRadius = 10
    eyeXOffset = 15
    eyeYOffset = 20
    mouthXOffset = 20
    mouthYOffset = 20

    chart = $('.user-smilies svg')
    chartWidth = chart.width()
    chartHeight = chart.height()

    bubbleLayout = d3.layout.pack()
      .sort(null)
      .value( (d) ->
        1
      )
      .size([chartWidth, chartHeight])
      .radius(80)
      .padding(20)

    nodes = bubbleLayout.nodes({
      children: scores
    }).filter( (d) ->
      d.depth > 0
    )

    happyColor = "green"
    angryColor = "red"
    zeroColor = "white"

    userScale = d3.scale.ordinal()
      .domain(participantIds)
      .rangeRoundBands([0, 900], 0.5)

    mouthControlScale = d3.scale.linear()
      .domain([-10, 10])
      .range([-faceRadius + mouthYOffset, faceRadius + mouthYOffset])
      .clamp(true)

    mouthPointScale = d3.scale.linear()
      .domain([-10, 10])
      .range([mouthYOffset * 2, 0])
      .clamp(true)

    eyeYScale = d3.scale.linear()
      .domain([-10,0,10])
      .range([eyeRadius, (eyeRadius * 0.2), eyeRadius])
      .clamp(true)

    faceColorScale = d3.scale.linear()
      .domain([-10, 0, 10])
      .range([angryColor, zeroColor, happyColor])
      .clamp(true)

    mouthPath = (datum) ->
      start = [mouthXOffset - faceRadius, mouthPointScale(datum.score)]
      finish = [faceRadius - mouthXOffset, mouthPointScale(datum.score)]
      control = [0, mouthControlScale(datum.score)]

      "M#{start[0]},#{start[1]} Q#{control[0]},#{control[1]} #{finish[0]},#{finish[1]}"

    leftEye = (ellipse) ->
        ellipse.attr('cx', -eyeXOffset)
        .attr('cy', -eyeYOffset)
        .attr('rx', eyeRadius)
        .attr('ry', (d) ->
          eyeYScale(d.score)
        )

    rightEye = (ellipse) ->
        ellipse.attr('cx', eyeXOffset)
        .attr('cy', -eyeYOffset)
        .attr('rx', eyeRadius)
        .attr('ry', (d) ->
          eyeYScale(d.score)
        )

    userGroups = d3.select('.user-smilies svg').selectAll('g.user-smiley-group').data(nodes, (d) ->
      d.user.get('id')
    )

    # Update
    g = userGroups.transition()
      .attr('data-score', (d) ->
        d.score
      )
      .attr('transform', (d) ->
        "translate(#{d.x}, #{d.y})"
      )
    face = g.select('circle.face-outer-circle')
      .attr('fill', (d) ->
        faceColorScale(d.score)
      )

    mouth = g.select('path.mouth')
      .attr('d', (d) ->
        mouthPath(d)
      )

    le = g.select('ellipse.left-eye')
    leftEye(le) if le

    re = g.select('ellipse.right-eye')
    rightEye(re) if re

    # Enter
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
        "translate(#{d.x}, #{d.y})"
      )

    g.append('circle')
      .classed('face-outer-circle', true)
      .attr('r', faceRadius)
      .attr('fill', (d) ->
        faceColorScale(d.score)
      )


    mouth = g.append('path')
      .classed('mouth', true)
      .attr('d', (d) ->
        mouthPath(d)
      )

    le = g.append('ellipse')
      .classed('eye', true)
      .classed('left-eye', true)
    leftEye(le)

    re = g.append('ellipse')
      .classed('eye', true)
      .classed('right-eye', true)
    rightEye(re)

})

`export default UserSmiliesController;`
