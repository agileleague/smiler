HeartbeatController = Ember.ObjectController.extend({
  needs: "experiment",

  refreshHandle: null

  actions: {
    buildChart: ->
      @refreshChart()
  }

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

    voteGs = d3.select('.heartbeat svg').selectAll('g').data(@get('votes').toArray(), (d) ->
      d.get('id')
    )

    g = voteGs.enter()
      .append('g')

    g.attr('class', 'vote-dot')
      .attr('data-vote-id', (d) ->
        d.get('id')
      )

    c = g.append('circle')
      .classed('upvote', (d) ->
        d.get('score') > 0
      )
      .classed('downvote', (d) ->
        d.get('score') < 0
      )
      .attr('cx', (d) ->
        timeScale(d.get('createdAt'))
      )
      .attr('cy', 40)
      .attr('r', 10)

    voteGs.transition().selectAll('circle')
      .attr('cx', (d) ->
        timeScale(d.get('createdAt'))
        )

    voteGs.exit()
      .remove()

    hook = Ember.run.later( =>
      @refreshChart()
    , 100)

    @set('refreshHandle', hook)

})

`export default HeartbeatController;`
