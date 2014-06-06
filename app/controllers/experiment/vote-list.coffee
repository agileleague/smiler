VoteListController = Ember.ObjectController.extend({
  needs: "experiment",

  voteChanged:( ->
    @get('votes').then( (vs) =>
      votes = vs
      Promise.all(
        votes.mapBy('user')
      )
    ).then( =>
      @refreshTable()
    )
  ).observes('votes.[]')


  refreshTable: ->
    votes = @get('votes').toArray()
    votes.sort( (a,b) ->
      d3.descending(a.get('createdAt'), b.get('createdAt'))
    )

    voteRow = d3.select('table.vote-list tbody').selectAll('tr').data(votes)

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
    voteRow.append('td').classed('score', true).text((d) ->
      d.get('score')
    )
    voteRow.append('td').classed('timestamp', true).html((d) ->
      t = moment.unix(d.get('createdAt'))
      "<time datetime='#{t.toISOString()}'>#{t.fromNow()}</time>"
    )
})

`export default VoteListController;`
