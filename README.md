# Campus Bites
A mobile application designed to help Georgia State University students discover affordable food options near campus while managing their weekly food budget.

## Team Members
Name         Student Id       Role
Caira Major  002681888        Data/Backend
Jack Lin     002703493        UI/Testing

## Features
Food Discovery - Browse and Search nearby GSU restaurants
Filter System - Filter by cuisine type and price range
Budget Tracker - Track weekly meal spending with warnings
Favorites - Save favorite meals and restaurants
Reviews - Add personal ratings and notes for restaurants 
AI Meal Matcher - Get restaurant suggestions based on mood, budget and time between classes

## Technologies Used
Flutter
Dart
SQLite
SharedPreferences
Path Provider

## Dependencies 
yaml 
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  shared_preferences: ^2.2.2

## Installation Instructions 
Clone the repository: git clone https://github.com/cairamajor/campus_bites
Navigate to the project folder: cd campus_bites
Install dependencies: flutter pub get
Run the app: flutter run

## Usage Guide
Splash Screen - App startup screen displaying the Campus Bites logo and name
Home Screen - Central hub with quick access to all features
Find Food- Browse and filter nearby GSU restaurants
Restaurant- View menu highlights, save to favorites, leave a review
Budget Tracker- Set weekly budget and log meal expenses
Favorites- View your saved meals and restaurants
AI Meal Matcher- Select your mood and time between classes get personalized suggestions

## Database Schema

## #restaurants 
Column            Type         Description
id                INTEGER      Primary Key
name              TEXT         Restaurant name
cuisine           TEXT         Cuisine type
price_range       TEXT         $, $$, or $$$
open_hours        TEXT         Opening hours
location          TEXT         Street Address
menu_highlights   TEXT         Popular menu items 
is_favorite       INTEGER        0 or 1

### saved_meals
Column            Type         Description
id                INTEGER      Primary Key
restaurant_id     INTEGER      Foreign Key
restaurant_name   TEXT         Restaurant name
meal_name         TEXT         Name of Meal
price             REAL         Meal of Price
saved_date        TEXT         Date saved

### reviews
Column            Type         Description
id                INTEGER      Primary Key
restaurant_id     INTEGER      Foreign Key
restaurant_name   TEXT         Restaurant name
rating            INTEGER      1 to 5 stars 
note              TEXT         Personal notes
review_date       TEXT         Date of review

### budget_history
Column            Type         Description
id                INTEGER      Primary Key
meal_name         TEXT         Name of Meal
amount            REAL         Amount spent
category          TEXT         Food category
date              TEXT         Date of expense

## Known Issues
- App requires Android device or emulator to run
- No cloud storage meaning all data is stored locally on device

## Future Enhancements
- Expand AI matcher with more mood options
- Add weekly spending charts and analytics
- Add photo support for meals and restaurants


## License
MIT License


