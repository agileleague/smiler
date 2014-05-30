AuthenticationController = Ember.Controller.extend({
  currentUser: null,

  init: ->
    @set('firebaseRef', new Firebase(window.ENV.FIREBASE_URL))
    @set('authRef', new FirebaseSimpleLogin(@get('firebaseRef'), (error, userResp) =>
      if error
        # Error
        console.log(error)
      else if userResp
        # Login
        @store.find('user', userResp.uid)
        .then( (u) =>
          user = u
          @set('currentUser', user)
        ).catch( (reason) =>
          # User not found
          user = @store.createRecord('user', {
            id: userResp.uid,
            username: userResp.username,
            email: userResp.thirdPartyUserData.email,
            displayName: userResp.displayName,
            avatarUrl: userResp.thirdPartyUserData.avatar_url,
            isModerator: false
          })
          user.save()
          .then( =>
            @set('currentUser', user)
          )
        )

      else
        # Logout
        @set('currentUser', null)
    ))

  isModerator:( ->
    if @get('currentUser.isModerator') then true else false
  ).property('currentUser.isModerator')

  isLoggedIn:( ->
    if @get('currentUser.id') then true else false
  ).property('currentUser')


  login: ->
    @get('authRef').login('github')

  logout: ->
    @get('authRef').logout()

})

`export default AuthenticationController;`
