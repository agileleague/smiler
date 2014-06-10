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

    timeNow = (new Date().getTime() / 1000)
    timeMin = timeNow - (180)

    timeScale = d3.scale.linear()
      .domain([timeMin, timeNow])
      .range([0, 600])

    stretchScale = d3.scale.linear()
      .domain([1,10])
      .range([0.1, 1])

    votesYMoveScale = d3.scale.linear()
      .domain([0,10])
      .range([0 + 60, -357.5 + 60])

    filteredVotes = @get('votes').filter( (v) ->
      timeScale(v.get('createdAt')) > 0
    )

    votesPerSecond = d3.nest()
      .key( (d) ->
        d.get('createdAt')
      )
      .sortKeys(d3.ascending)
      .rollup( (leaves) ->
        {
          votes: leaves.length
          createdAt: leaves[0].get('createdAt')
        }
      )
      .entries(filteredVotes)

    voteGs = d3.select('.heartbeat svg').selectAll('g').data(votesPerSecond, (d) ->
      d.values.createdAt
    )

    g = voteGs.enter()
      .append('g')

    g.attr('class', 'vote-dot')

    c = g.append('path')
      .classed('vote', true)
      .attr('transform', (d) ->
        translate = "translate(#{timeScale(d.values.createdAt)}, #{votesYMoveScale(d.values.votes)})"
        scale1 = "scale(0.1, #{stretchScale(d.values.votes)})"
        "#{translate} #{scale1}"
      )
      .attr('d', @get('ecgPath'))

    voteGs.transition().select('path.vote')
      .attr('transform', (d) ->
        translate = "translate(#{timeScale(d.values.createdAt)}, #{votesYMoveScale(d.values.votes)})"
        scale1 = "scale(0.1, #{stretchScale(d.values.votes)})"
        "#{translate} #{scale1}"
      )
      .attr('d', @get('ecgPath'))

    voteGs.exit()
      .remove()

    hook = Ember.run.later( =>
      @refreshChart()
    , 100)

    @set('refreshHandle', hook)

})

`export default HeartbeatController;`
