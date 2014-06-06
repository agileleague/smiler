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

    filteredVotes = @get('votes').filter( (v) ->
      timeScale(v.get('createdAt')) > 0
    )

    voteGs = d3.select('.heartbeat svg').selectAll('g').data(filteredVotes.toArray(), (d) ->
      d.get('id')
    )

    g = voteGs.enter()
      .append('g')

    g.attr('class', 'vote-dot')
      .attr('data-vote-id', (d) ->
        d.get('id')
      )

    c = g.append('path')
      .classed('vote', true)
      .classed('upvote', (d) ->
        d.get('score') > 0
      )
      .classed('downvote', (d) ->
        d.get('score') < 0
      )
      .attr('transform', (d) ->
        translate = "translate(#{timeScale(d.get('createdAt'))},0)"
        scale = "scale(0.1)"
        "#{translate} #{scale}"
      )
      .attr('d', (d) =>
        if d.get('score') > 0
          @get('thumbUpPath')
        else
          @get('thumbDownPath')
      )


    voteGs.transition().select('path.vote')
      .attr('transform', (d) ->
        translate = "translate(#{timeScale(d.get('createdAt'))},0)"
        scale = "scale(0.1)"
        "#{translate} #{scale}"
      )
      .attr('d', (d) =>
        if d.get('score') > 0
          @get('thumbUpPath')
        else
          @get('thumbDownPath')
      )

    voteGs.exit()
      .remove()

    hook = Ember.run.later( =>
      @refreshChart()
    , 100)

    @set('refreshHandle', hook)

})

`export default HeartbeatController;`
