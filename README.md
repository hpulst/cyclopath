# Cyclopath

A Courrier app that includes functionality that allows the courier to receive orders, view order details, and deliver it crazy fast. "All User Input Equals Error" is the mantra when looking at UX.

## Screenshots

<table>
    <tr>
        <td><img src="./images/screenshot_login.jpg" width="200" /></td>
        <td><img src="./images/screenshot_offline.jpg" width="200" /></td>
        <td><img src="./images/screenshot_waiting.jpg" width="200" /></td>
        <td><img src="./images/screenshot_route.jpg" width="200" /></td>
    </tr>
    <tr>
        <td><img src="./images/screenshot_order.jpg" width="200" /></td>
        <td><img src="./images/screenshot_orderlist.jpg" width="200" /></td>
        <td><img src="./images/screenshot_dialog.jpg" width="200" /></td>
        <td><img src="./images/screenshot_returning.jpg" width="200" /></td>
    </tr>
</table>

## Screen recording

[![IMAGE ALT TEXT](http://img.youtube.com/vi/o6eg_F9Z9BQ/0.jpg)](http://www.youtube.com/watch?v=o6eg_F9Z9BQ "Video Title")

## Roadmap

**Must have features:**

- [x] Sign in as a courier
  - [x] Sign out

- [x] Select starting time using bottom sheet
  - [x] Tap to open
  - [x] Drag to open
  - [x] Open to specific height
  - [x] Tap to close
  - [x] Drag to close

- [x] View order details
  - [x] View delivery location
  - [x] View direction on map using flutter_polyline_points
  - [x] Button to start turn-by-turn navigation
  
- [x] View list of orders
  - [x] Build ListTile
  - [x] View order queue with tap on list button  

**Nice to have features:**

- [x] View route preview on order
- [x] Destination window of marker with distance & duration
- [x] Show navigation Button
- [ ] See VerticalProgressIndicator when going online
- [ ] Push-notification
- [ ] Get realtime updates with Cloud Firestore
- [ ] Offline capability using package 'retry'
- [ ] time.periodic remote config
- [ ] Insert sound feature
  - [ ] Delivery sound
- [ ] Blast colorful confetti all over the screen when deliveries complete
- [ ] Automatically change status of user to "waiting" when close to store
- [ ] Make every Map available  
