HeartbeatController = Ember.ObjectController.extend({
  needs: "experiment",

  refreshHandle: null

  actions: {
    buildChart: ->
      @refreshChart()
  }

  thumbUpPath: "M510.276,252.508c-6.134-22.888-32.47-50.8-32.47-50.8s-18.548-1.631-45.827,1.443c-21.084,2.383-49.078,9.806-67.219,8.908c-22.697-1.123-27.699-17.316-27.699-17.316s11.294-27.455,21.1-54.276c13.337-36.471,17.916-75.324,17.916-75.324s-4.022-36.421-23.101-53.246c-16.229-14.322-39.606-9.46-39.606-9.46s-3.796,46.808-24.186,84.734c-17.749,33.014-48.272,56.202-48.272,58.797c0,2.134-18.859,22.431-32.836,49.096c-11.315,21.6-16.546,48.343-28.686,65.426c-12.022,16.917-30.448,19.25-30.448,19.25v199.272c0,0,35.921,1.293,66.511,7.63c26.207,5.44,47.751,16.053,47.751,16.053s46.872,11.354,89.159,10.234c36.75-0.966,69.701-14.41,69.701-14.41s22.992-6.969,34.836-22.298c11.839-15.329,12.542-39.014,12.542-39.014s18.48-13.466,25.218-34.8c5.723-18.114-0.138-44.634-0.138-44.634s13.49-17.669,14.48-36.195c1.094-20.406-10.296-41.839-10.296-41.839S513.914,266.106,510.276,252.508zM-0.162,265.803l16.726,227.143l103.115,1.395l-2.791-234.109L-0.162,265.803z"

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
        rotate = if d.get('score') < 0 then "rotate(180,300,300)" else "rotate(0)"
        "#{translate} #{scale} #{rotate}"
      )
      .attr('d', @get('thumbUpPath'))

    voteGs.transition().select('path.vote')
      .attr('transform', (d) ->
        translate = "translate(#{timeScale(d.get('createdAt'))},0)"
        scale = "scale(0.1)"
        rotate = if d.get('score') < 0 then "rotate(180,300,300)" else "rotate(0)"
        "#{translate} #{scale} #{rotate}"
      )

    voteGs.exit()
      .remove()

    hook = Ember.run.later( =>
      @refreshChart()
    , 100)

    @set('refreshHandle', hook)

})

`export default HeartbeatController;`
