Router = Ember.Router.extend({
  location: ENV.locationType
})

Router.map ->
  @route('experiments')

`export default Router;`
