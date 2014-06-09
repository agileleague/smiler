`import svgIcons from "smiler/utils/svg-icons";`

VoteListController = Ember.ObjectController.extend({
  needs: "experiment",

  thumbUpPath: svgIcons.thumbUpPath

  thumbDownPath: svgIcons.thumbDownPath

  voteChanged:( ->
    @get('votes').then( (votes) =>
      Promise.all(
        votes.mapBy('user')
      )
    ).then( =>
      Ember.run.once(@, =>
        @refreshTable()
      )
    )
  ).observes('votes.@each')


  refreshTable: ->
    console.log("refresh")
    votes = @get('votes').toArray()
    votes.sort( (a,b) ->
      d3.descending(a.get('createdAt'), b.get('createdAt'))
    )

    voteRow = d3.select('table.vote-list tbody').selectAll('tr').data(votes, (d) ->
      d.get('id')
    )

    # Update
    voteRow.classed('new', false)
    voteRow.select('td.username').html( (d) ->
      "<img src='#{d.get('user.avatarUrl')}' />"
    )
    voteRow.select('td.timestamp').html( (d) ->
      t = moment.unix(d.get('createdAt'))
      "<time datetime='#{t.toISOString()}'>#{t.fromNow()}</time>"
    )

    # Enter
    voteRow = voteRow.enter().insert('tr', 'tr.vote-row').classed('vote-row', true).classed('new', true)
    voteRow.append('td').classed('username', true).html((d) ->
      "<img src='#{d.get('user.avatarUrl')}' />"
    )
    voteRow.append('td').classed('score', true).append('svg').append('path')
      .attr('transform', "scale(0.05)")
      .attr('d', (d) =>
        if d.get('score') > 0
          @get('thumbUpPath')
        else
          @get('thumbDownPath')
      )
    voteRow.append('td').classed('timestamp', true).html((d) ->
      t = moment.unix(d.get('createdAt'))
      "<time datetime='#{t.toISOString()}'>#{t.fromNow()}</time>"
    )
})

`export default VoteListController;`
