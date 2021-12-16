# Final Project: NYC Artsy Date Planner 
## Connie Xu 

#### Type of Project: A

## Project Description  
### Background  
New York City is a center with a burgeoning art scene. Each weekend, there exist countless art events unique to the NYC area. For everyone from locals looking for date ideas or group get-togethers to tourists looking to do something novel, the NYC ArtBeat API is able to provide easy access to current and upcoming art-based events within a walkable / bikeable distance (500-3000 meters). 

### Purpose
The purpose of my final project is to develop an API-based package that can plan art-based social meetings, outings, and dates. In its simplest form, the user will input details about their planned meeting address / home address (as well as optional specifications about ticket pricing, radius from meeting place, etc.), and recieve information about local art events in a dataframe and map format (as needed).

In addition, to make this project more practical for end users (people in New York metro area trying to plan meetups around art-based events), I also wanted to add features that would:
  (a) filter for ticket availability and facilitate ticket purchasing, or 
  (b) include nearby restaurants with reasonably high reviews (e.g., 4.3+ rating on Google Places) within a walkable radius (e.g., 3000 meters)

I plan to primarily leverage the **NYC ArtBeat API** to fulfill this goal, but will also be relying on the Google Maps API (accessed through the [googlemaps package](https://github.com/googlemaps/google-maps-services-python)) to facilitate features such as geocoding and potential restaurant reccomendation features.  

### API's Used: 

**NYC ArtBeat API** 
The NYC Art Beat API is used to access data about current and upcoming arts events around the New York Metro Area. It is a basic REST API, and does not require any API key to access due to its relatively low user base and relatively smaller dataset.

* API Documentation: https://www.nyartbeat.com/resources/doc/api
* API Retrieval URL: http://www.nyartbeat.com/list/event_searchNear
* Input Parameters: The following are some of the most significant input parameters. 
  * Latitude and Longtitude Coordinates: **required input** (float/int format) specifying meeting / starting point
  * Schedule: "current" vs "upcoming" 
  * SearchRange: Radius of art-based events (500m - 3000m) 
  * Description	: specify whether you want events with a description 
  * Free: binary variable specifying whether to filter for free events

* Output: The output is in XML Format, including the Name and Description of an event, as well as location and dates, pricing, and media of photography. While there is an output field for image(s), I have not thus far seen any within the resulting XML's. Included below are two sampled rows of output data in df format: 

| Name                    | Media     | Price   | DateStart   | DateEnd    | PermanentEvent |   Distance | Datum   |   Latitude |   Longitude | Party             |
|-------------------------|-----------|---------|-------------|------------|----------------|------------|---------|------------|-------------|-------------------|
| Kadir van Lohuizen “Rising Tide: Visualizing the Human Costs of the Climate Crisis” | 2D: Photography  | Suggested Admission: Adults $10, Seniors and Students $6, Families $20 (max. 2 adults) Children 12 and under Free       | 2021-04-16  | 2021-12-31 |             0 |    1876.71 | world   |    40.7924 |    -73.9527 | nan  | 
| Joe Ramiro Garcia “Keep Off the Grass”  | 2D: Painting     | Free  | 2021-11-20  | 2021-12-23 |                0 |    2265.4  | world   |    40.8012 |    -73.937  | Opening Reception |

**Google Maps** 
As shown by the specs above, one of the input parameters is latitude and longitude of the user's starting point. Keeping in mind the fact that individuals using this API would not easily know their latitude and longitude parameters, I wanted to improve ease of use by adding a geocoder into the package so that the user can simply input the address or a well-known landmark for a meeting place / starting address and generate an output. To this point, I am going to use the Google Maps API, as accessed through the python package `googlemaps`.

This API does require a key, which I obtained and saved locally for myself. I will need to ensure that this component of the key is documented as a parameter to be input by the user(s) of the package. This will be documented in the package README and PyPi documentation. 

* API Documentation: https://developers.google.com/maps/documentation/
* API Retrieval URL: https://maps.googleapis.com/maps/api/
* Package Documentation: https://github.com/googlemaps/google-maps-services-python and https://pypi.org/project/googlemaps/
* Input: varies - for geocoding, the address or landmark name works fine. 
* Output: varies - currently, we are only outputting one simple data point (e.g., latitude and longtitude for geocoding). 

### Potential Challenges 
Currently, I am having trouble with the scoping of this project. As discussed in the **Purpose** section above, I wanted to add details about ticketing availability but have had trouble finding an API that could help us easily gain these details regardless of art institute / organization. I looked into the use of stubhub and ticketmaster, but neither platform is used for a large proportion of NYC art institutes / organizations. 

I also have had limited experience with google maps places, which has to do with the second feature (i.e., selecting restaurants with 4.3+ star ratings near the starting/meeting place and near the art-based event). This should prove less of a challenge as I already have the API key access and documentation.

If these challenges limit my implementation of the project, I will still have a deliverable (albeit a simpler one). I hope however that I will be able to implement both of these features, as I feel that they are ultimately important for this package to be truly useful to the end user specified. 

*Note: I am also having a bit of trouble with idea generation beyond these features. Any feedback is appreciated about how to most effectively expand on my initial function developed as part of [Homework 8](https://github.com/QMSS-G5072-2021/Xu_Connie_Ye/blob/master/hw08/Homework_8.ipynb)

## Detailed Procedure
*italicized bullet points are to-dos that are currently in optional* 
* Obtain and store API Key for Google Maps API; install **googlemaps** package
* Develop function outputting basic dataframe from NYC ArtBeats Parameters 
  * Set up google maps API to geocode Latitude and Longitude parameters using address for input 
  * Leverage geocoded output as input parameters in NYC ArtBeats API GET command
  * Allow for important NYC ArtBeats Parameters (e.g., free/not free, query radius, max results) as keywords in function
  * Introduce commands for input validation in function 
  * Reshape XML output into dataframe format 
* Develop function outputting map from NYC ArtBeats Parameters
  * Leverage df from previous function to output a basic interactive map of manhattan with pins in the relevant radius. 
* *Add to function 1 by incorporating data about ticket availability if possible using either the output dataframe or another ticket API.*  
* *Develop function using googlemaps package to locate nearby restaurants that are within 3000 meters of the starting point and of the art event.* 
* Run Pytests on package functions and generate report for pytest (to use in package documentation) 
* Publish Python Package with documentation 

I welcome any feedback about how best to make this package usable and interesting to end users.
