# Garmin Quote Widget
An app for a garmin wearable device that displays a daily quote from the terrifying quote book of Alex.

# Backend
This widget sends requests to a backend to download the quotes. Due to memory limitations of the wearable, quotes must be downloaded in groups (currently of 15), which I have called "pages". The backend provides an endpoint that returns the total number of pages needed to download all of the quotes. Another endpoint takes a parameter, the page number, for which all quote can be downloaded from. The backend also provides a simple HTML form for submitting new quotes.

# Backend URL
The backend I created is not available publicly. To set the URL of the backend, create a file called `backendURL.xml` in the `resources/strings` folder with the following contents:
```xml
<resources>
    <string id="backend_url" scope="background">YOUR_BACKEND_URL_HERE</string>
</resources>
```

# Code
There is a glance view class that just provides some text for the widget glance view so connect IQ doesn't complain. There is a main widget view, this displays the quote of the day.

The update service runs once every 24hrs and pulls all the quotes from the database, caches them locally, and then picks a new random quote for the day. The caching means that new quotes can be picked even if offline for multiple days. This code is all in the `backendInteractionLogic.mc` class, the `quoteUpdateService` creates an instance of it before syncing. The sync can also be triggered manually by pressing button 4 (on the device this app was built for, buton 4 is the top right button).

Finally the main app class schedules the background task, and listens for sync completions, on which it will refresh the displayed quote (if currently on screen) to match the new quote of the day.

#### Dev Key
Yes I know I have included the developer key in this repo, and generally they should be kept secret, but this app will not be published and I will not be using this key for aything else.