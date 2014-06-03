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
    eyeRadius = 10
    eyeXOffset = 15
    eyeYOffset = 20
    mouthXOffset = 20
    mouthYOffset = 20

    happyColor = "green"
    angryColor = "red"
    zeroColor = "white"

    userScale = d3.scale.ordinal()
      .domain(participantIds)
      .rangeRoundBands([0, 600], 0.5)

    mouthControlScale = d3.scale.linear()
      .domain([-10, 10])
      .range([-faceRadius + mouthYOffset, faceRadius + mouthYOffset])

    mouthPointScale = d3.scale.linear()
      .domain([-10, 10])
      .range([mouthYOffset * 2, 0])

    eyeYScale = d3.scale.linear()
      .domain([-10,0,10])
      .range([eyeRadius, (eyeRadius * 0.2), eyeRadius])

    faceColorScale = d3.scale.linear()
      .domain([-10, 0, 10])
      .range([angryColor, zeroColor, happyColor])

    mouthPath = (datum) ->
      start = [mouthXOffset - faceRadius, mouthPointScale(datum.score)]
      finish = [faceRadius - mouthXOffset, mouthPointScale(datum.score)]
      control = [0, mouthControlScale(datum.score)]

      "M#{start[0]},#{start[1]} Q#{control[0]},#{control[1]} #{finish[0]},#{finish[1]}"

    leftEye = (ellipse) ->
      ellipse.classed('eye', true)
        .classed('left-eye', true)
        .attr('cx', -eyeXOffset)
        .attr('cy', -eyeYOffset)
        .attr('rx', eyeRadius)
        .attr('ry', (d) ->
          eyeYScale(d.score)
        )

    rightEye = (ellipse) ->
      ellipse.classed('eye', true)
        .classed('right-eye', true)
        .attr('cx', eyeXOffset)
        .attr('cy', -eyeYOffset)
        .attr('rx', eyeRadius)
        .attr('ry', (d) ->
          eyeYScale(d.score)
        )

    userGroups = d3.select('.user-smilies svg').selectAll('g.user-smiley-group').data(scores, (d) ->
      d.user.get('id')
    )


    # Update
    g = userGroups
      .attr('data-score', (d) ->
        d.score
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
      .attr('fill', (d) ->
        faceColorScale(d.score)
      )
      .attr('fill-opacity', 0.3)


    mouth = g.append('path')
      .classed('mouth', true)
      .attr('d', (d) ->
        mouthPath(d)
      )

    le = g.append('ellipse')
    leftEye(le)

    re = g.append('ellipse')
    rightEye(re)

})

`export default UserSmiliesController;`
