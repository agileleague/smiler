FirebaseAdapter = DS.FirebaseAdapter.extend({
  firebase: new Firebase(window.ENV.FIREBASE_URL)
})

`export default FirebaseAdapter;`
