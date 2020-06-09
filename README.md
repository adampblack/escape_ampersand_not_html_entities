# Escape ampersand not HTML entities

I wrote this function for a client circa 2018 and have since used it once again in 2019.

Many applications will turn characters into HTML entities when storing the data in the database.

The two main rules are:
* Never trust database input
* Always escape database output

However the problem arises when someone has used & symbol within the data and you cannot distinuish between the & symbol and the HTML entities.

This is the problem that this function solves.

This function was written for **SQL server**.
