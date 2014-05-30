LineOverallScoreController = Ember.ObjectController.extend({
  needs: "experiment",

  historyLengthInS: 600,

  refreshHandle: null,

  actions: {
    buildChart: ->
      @refreshChart()

    setHistoryLength: (length) ->
      if @get('refreshHandle')
        Ember.run.cancel(@get('refreshHandle'))

      @set('historyLengthInS', length)

  }

  refreshChart:( ->
    @set('refreshHandle', null)

    allVotes = @get('votes').toArray()

    totalScore = 0
    totalScoreByTime = d3.nest()
      .key( (d) ->
        # Group by their second of creation
        epochMillis = d.get('createdAt') * 1000
      )
      .sortKeys(d3.ascending)
      .rollup( (leaves) ->
        score = d3.sum(leaves, (d) ->
          d.get('score')
        )
        totalScore += score
        totalScore
      )
      .entries(allVotes)


    return unless totalScoreByTime.length > 0

    [scoreMin, scoreMax] = d3.extent(totalScoreByTime, (s) ->
      s.values
    )

    timeMax = new Date()
    timeMin = if @get('historyLengthInS') > 0
      new Date(timeMax.getTime() - @get('historyLengthInS') * 1000)
    else
      # Lifetime, so get the time of the first vote
      new Date(parseInt(totalScoreByTime[0].key))

    timeScale = d3.time.scale()
      .domain([timeMin, timeMax])
      .range([0, 600])

    yScale = d3.scale.linear()
      .domain([scoreMin, scoreMax])
      .range([200, 0])

    lineGenerator = d3.svg.line()
      .x( (d) ->
        # Have to convert back to Dates from Unix Epoch seconds
        timeScale(new Date(parseInt(d.key)))
      )
      .y( (d) ->
        yScale(d.values)
      )

    lineGroup = d3.select('.line-overall-score svg').selectAll('g').data([totalScoreByTime])

    g = lineGroup.enter()
      .append('g')
      .classed('line-container', true)

    g.append('path')
      .attr('d', lineGenerator)

    lineGroup.select('g.line-container path')
      .attr('d', lineGenerator)

    hook = Ember.run.later( =>
      @refreshChart()
    , 100)

    @set('refreshHandle', hook)

  ).observes('votes.[]', 'historyLengthInS')

})

`export default LineOverallScoreController;`
