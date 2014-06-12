`import svgIcons from "smiler/utils/svg-icons";`

HeartbeatController = Ember.ObjectController.extend({
  needs: "experiment",

  refreshHandle: null

  actions: {
    buildChart: ->
      @refreshChart()
  }

  thumbUpPath: svgIcons.thumbUpPath

  thumbDownPath: svgIcons.thumbDownPath

  ecgPath: svgIcons.ecgPath

  voteChanged:( ->
    if @get('refreshHandle')
      Ember.run.cancel(@get('refreshHandle'))

    # For some reason, EmberFire sets the votes array to empty, then refills it
    @refreshChart() unless @get('votes.length') == 0
  ).observes('votes.[]')

  refreshChart: ->
    @set('refreshHandle', null)

    ecgWidth = 512
    shrinkScale = 0.33
    singleUnit = ecgWidth * shrinkScale
    windowSeconds = 10
    width = $('.heartbeat svg').width()

    timeNow = moment(new Date())
    timeMin = moment(timeNow).subtract('s', windowSeconds)

    timeScale = d3.time.scale()
      .domain([timeMin.toDate(), timeNow.toDate()])
      # Extend the width a little so the heartbeats appear a bit offscreen
      .range([0, width * 1.05])

    filteredVotes = @get('votes').filter( (v) ->
      # We give it some wiggle room into the negative so the pulses fade off the edge instead of abruptly disappearing
      timeScale(moment.unix(v.get('createdAt'))) > -1000
    )

    votesPerSecond = d3.nest()
      .key( (d) ->
        d.get('createdAt')
      )
      .sortKeys(d3.ascending)
      .rollup( (leaves) ->
        {
          votes: leaves.length
          createdAt: moment.unix(leaves[0].get('createdAt'))
        }
      )
      .entries(filteredVotes)

    chart = d3.select('.heartbeat svg')

    pulseLine = chart.selectAll('g.pulse-line').data([1])

    pulseLine.enter().append('g')
      .classed('pulse-line', true)
      .append('line')
      .attr('x1', 0)
      .attr('y1', 90)
      .attr('x2', width)
      .attr('y2', 90)

    voteGs = chart.selectAll('g.vote-dot').data(votesPerSecond, (d) ->
      d.values.createdAt
    )

    g = voteGs.enter()
      .append('g')

    g.attr('class', 'vote-dot')
      .attr('transform', (d) ->
        "translate(#{timeScale(d.values.createdAt)}, 0)"
      )

    back = g.append('rect')
      .classed('background', true)
      .attr('width', singleUnit - 5)
      .attr('height', singleUnit)

    c = g.append('path')
      .classed('pulse', true)
      .attr('transform', (d) ->
        "scale(0.33, 0.33)"
      )
      .attr('d', @get('ecgPath'))

    v = voteGs.transition().duration(100).ease('linear')
      .attr('transform', (d) ->
        "translate(#{timeScale(d.values.createdAt)}, 0)"
      )

    voteGs.exit()
      .remove()

    hook = Ember.run.later( =>
      @refreshChart()
    , 100)

    @set('refreshHandle', hook)

})

`export default HeartbeatController;`
