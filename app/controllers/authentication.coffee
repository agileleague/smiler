AuthenticationController = Ember.Controller.extend({
  isLoggedIn: false,

  firebaseUrl: "https://smiler.firebaseio.com",

  init: ->
    @set('firebaseRef', new Firebase(@get('firebaseUrl')))
    @set('authRef', new FirebaseSimpleLogin(@get('firebaseRef'), (error, user) =>
      if error
        # Error
        console.log(error)
      else if user
        # Login
        @set('isLoggedIn', true)
      else
        # Logout
        @set('isLoggedIn', false)
    ))

  login: ->
    @get('authRef').login('github')

  logout: ->
    @get('authRef').logout()

})

`export default AuthenticationController;`
