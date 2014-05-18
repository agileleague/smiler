Router = Ember.Router.extend({
  location: ENV.locationType
})

Router.map ->
  @resource('experiments', ->
    @route('new')
  )

`export default Router;`
