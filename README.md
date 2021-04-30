# Cyclopath

A Courrier app that includes functionality that allows the courier to receive orders, view order details, and deliver it crazy fast.

**Must have features:**

- [ ] Sign in as a courier
  - [x] Sign out
  - [ ] Implement SharedPreferences
  - [ ] black design

- [ ] Select starting time using bottom sheet
  - [ ] Tap to open
  - [x] Drag to open
  - [x] Open to specific height
  - [ ] Tap to close
  - [x] Drag to close

- [ ] View status(call Store/online/offline/riding stats/logout)
  - [ ] Top left appbar Icon

- [ ] View list of new orders
  - [x] List orders
  - [x] Build ListTile
  - [ ] Live orders receiving function

- [ ] View order details
  - [ ] View delivery location
  - [ ] View direction on map
  - [ ] Start turn-by-turn navigation
  
- [ ] View order queue with tap on list button

- [ ] Implements the order repository using SharedPreferences as a data source.

**Nice to have features:**

- [ ] View route preview on order
- [ ] See VerticalProgressIndicator when going online
- [ ] Push-notification sync

**Current Feature Sprint:**

- [ ] Write fetch method for JSON with StreamBuilder
  - [ ] Notify UserSession to switch to delivery
  - [ ] show first order
  