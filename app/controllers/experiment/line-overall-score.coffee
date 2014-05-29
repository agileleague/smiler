LineOverallScoreController = Ember.ObjectController.extend({
  needs: "experiment",

  actions: {
    buildChart: ->
      @refreshChart()
  }

  refreshChart:( ->

    # Now and 3 minutes ago
    timeNow = new Date()
    timeMin = timeNow.getTime() - (180 * 1000)


    allVotes = @get('votes').toArray()

    totalScore = 0
    totalScoreByTime = d3.nest()
      .key( (d) ->
        # Floor the createdAt to the nearest 10-second mark, to group them in 10-second increments
        epochMillis = Math.floor(d.get('createdAt') / 1.0) * 1 * 1000
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

    scoreCount = totalScoreByTime.length
    #timeMin = new Date(parseInt(totalScoreByTime[0].key))
    timeMin = new Date(new Date().getTime() - (180 * 1000))
    timeMax = new Date(parseInt(totalScoreByTime[scoreCount - 1].key))

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

  ).observes('votes.[]')

})

`export default LineOverallScoreController;`
