# Cyclopath

A Courrier app that includes functionality that allows the courier to receive orders, view order details, and deliver it crazy fast.

**Must have features:**

- [ ] Sign in as a courier
  - [x] Sign out

- [ ] Select starting time using bottom sheet
  - [ ] Tap to open
  - [x] Drag to open
  - [x] Open to specific height
  - [ ] Tap to close
  - [x] Drag to close

- [ ] View status(call Store/online/offline/riding stats/logout)
  - [ ] Top left appbar Icon

- [x] View list of new orders
  - [x] List orders
  - [x] Build ListTile

- [ ] View order details
  - [x] View delivery location
  - [ ] View direction on map using flutter_polyline_points
  - [ ] Button to start turn-by-turn navigation
  
- [ ] View order queue with tap on list button

**Nice to have features:**

- [ ] View route preview on order
- [ ] See VerticalProgressIndicator when going online
- [ ] Push-notification sync
- [ ] Implement SharedPreferences to store login info
- [ ] Switch to black design
- [ ] Live orders receiving function
- [ ] Implements the order repository using Firebase as a data source
- [ ] Implement offline capability using package 'retry'

**Current Feature Sprint:**

- [x] Write fetch method for JSON with StreamBuilder
- [ ] Notify UserSession to switch to delivery
- [ ] Show first order
  