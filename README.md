# Collaborative to-do app

A collaborative to-do app, written in Swift for iOS. It uses PubNub's global data stream network to make this a realtime app.

A user may create or subscribe to a to-do list, view all of the lists they are subscribed to, view all the tasks in a list and create or delete tasks from a list in realtime. This app has been written for a tutorial, https://www.pubnub.com/blog/2016-06-21-ios-to-do-app-tutorial-built-using-swift/.


Add gif here


# Project structure

The project has four view controllers, all embedded in a navigation controller. 


Storyboard image here


# Project flow

1. The first view controller will take user input in a text field for the channel they want to create or join. 
2. The “Go!” button will segue them to the second view controller which is a table view of all the channels they are currently subscribed to. 
3. Once a cell in the table view is selected, the app will segue to the third view controller which shows all to-do tasks that weren’t deleted from this channel.
4. From there the user can hit the + button which will segue to the fourth view controller where they can add a task to the current channel they are on. 

