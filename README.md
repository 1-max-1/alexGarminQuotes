# Garmin Quote Widget
An app for a garmin wearable device that displays a daily quote from the terrifying quote book of Alex.

# Backend
This widget sends request to a simple backend hosted on my awardspace account - just gets all quotes from the database and returns them as JSON. New quotes can be added to the database [here](externalrequests.yaboichips.ga/GarminQuotes).

# Code
There is a glance view class that just provides some text for the widget glance view so connect IQ doesn't complain. There is a main widget view, this just displays the quote of the day. The update service runs once every 24hrs and pulls all the quotes from the database, caches them locally, and then picks a new random quote for the day. The caching means that new quotes can be picked even if offline for multiple days. Finally the main app class just schedules the service and sends back instances of the view classes for the system to use.