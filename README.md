# CO2 Finland
CO2 Finland is a mobile application that shows CO2 emissions of electricity production and consumption from selected timeline in Finland. \
CO2 Finland is programmed using Dart programming language and uses Flutter framework. Emission data is fetched from Fingrid Open Data service (https://data.fingrid.fi/en). \
Line charts are drawn using Syncfusion Flutter Charts. \
This project is made by Tomi Isojärvi as a project assignment for Oulu University of Applied Sciences (OAMK).

## How to build
### Install Flutter
Visit https://docs.flutter.dev/get-started/install and install Flutter framework for your platform.
### Add the package dependencies to the app
Open the project directory and install package dependencies to the project: \
`cd co2_finland` \
`flutter pub get`
### Add API key to the project
Visit https://data.fingrid.fi/en to acquire your personal API key.
Create `.env` file at the project directory and at the following: \
`API_KEY=<YOUR API KEY>`
At the project directory run the following command: \
`dart run build_runner build -d`
### Build the project
#### Android
