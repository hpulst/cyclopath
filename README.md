# Cyclopath

A Courrier app that includes functionality that allows the courier to receive orders, view order details, and deliver it crazy fast.

**Must have features:**

- [ ] Sign in as a courier
  - [ ] Sign out

- [ ] View status(call Store/online/offline/riding stats/logout)
  - [ ] Top left appbar Icon

- [ ] View order details
  - [x] View delivery location
  - [x] View direction on map using flutter_polyline_points
  - [ ] Button to start turn-by-turn navigation
  
- [x] View list of orders
  - [x] Build ListTile
  - [x] View order queue with tap on list button

- [x] Select starting time using bottom sheet
  - [x] Tap to open
  - [x] Drag to open
  - [x] Open to specific height
  - [x] Tap to close
  - [x] Drag to close

**Nice to have features:**

- [x] View route preview on order
- [ ] See VerticalProgressIndicator when going online
- [ ] Push-notification sync
- [ ] SharedPreferences to store login info
- [ ] Switch to black design
- [ ] Get realtime updates with Cloud Firestore
- [ ] Order repository using Firebase as a data source
- [ ] Offline capability using package 'retry'
- [ ] time.periodic remote config
- [ ] Delivery sound
- [ ] Show navigation Button

**Start of Day (SOD) 18.06:**

- [ ] Destination marker with distance & duration
- [ ] Move CameraPosition to bound

**End of Day (EOD) 18.06:**
  
**End of Week (EOW) 24:**

- [ ] publish App



**Current Feature Sprint:**

- update polylines when location changes
  - call getcurrentposition
  - call getPolylines
  - update marker (duration, distance)
  - upadate CameraPosition

- create polylines when active Orders available
 - 

**Name all possible solutions:**
  
- 