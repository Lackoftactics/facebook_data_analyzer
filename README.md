# facebook_data_analyzer

Facebook data analyzer as seen on [I analyzed my facebook data and it's story of shyness, loneliness, and change](https://medium.com/@przemek_/i-analyzed-my-facebook-data-and-its-story-of-shyness-loneliness-and-change-7f4e0ec3a952)

Analyze facebook copy of your data. Download zip file from facebook and get info about friends ranking by message, vocabulary,  contacts, friends added statistics and more.

# How to run

**Remember you need to use english language(US) on facebook for download**

 It won't work if you use different language because of date formatting, different titles on pages. This script uses `nokogiri` internally to parse data.

1. Go to settings on facebook and switch to english language(US), you can later go back to your native langauge.
2. From facebook settings, request copy of your data
3. You should get mail back in about 30 minutes
4. Download zip from link provided in email
5. Extract the file and then get path to catalog with copy of your data. In my case it was: `/Users/przemyslawmroczek/Downloads/facebook-przemekmroczek90/`
6. Clone this repository with script
7. You need to install `ruby`, `gem bundler`, `gem nokogiri`, `gem axlsx`. There are extensive tutorials in the web how to do it and it' beyond this readme
8. Go to folder where you cloned `facebook_data_analyzer`
9. Run `ruby analyze_facebook_data.rb path_to_catalog_with_copy_of_facebook_data` in my case this command looked like: `ruby analyze_facebook_data.rb /Users/przemyslawmroczek/Downloads/facebook-przemekmroczek90/`
10. You will see the script running and analyzing your conversations. At the end you will see it generated new excel file `facebook_analysis.xlsx`

Optional:
If the `DEBUG` environment variable is present, the script will print the name of every message as it is analyzed instead of the total count.
```bash
ruby analyze_facebook_data.rb example/facebook-monaleigh
Analyzing 5 messages...
Finished 5 messages...
```
```bash
DEBUG=true ruby analyze_facebook_data.rb example/facebook-monaleigh
Analyzing conversation with: Abbie Carter
Analyzing conversation with: Allison Walker
Analyzing conversation with: Cindi Gray
Analyzing conversation with: Kate Hunter
Analyzing conversation with: Suzanne Nash
```

# What's inside

* Ranking of friends by messages (number of messages sent, who sent more, how many words, characters in conversation)
* Your most used words in conversations, the most frequent words from english language and also polish (my native language) are deleted. So you get quite good and interesting results
* Your overall statistics of messaging: total number of messages, words, characters, unique words
* How many messages were sent by period: month, week, year, hour. So you can easily get what type of writer you are: night owl vs. early bird. Find your most busy messaging days
* How your history of making friends looked like? Breaked down by month, year, weekend vs. working day,

# Contributing

Please consider running your changes with `ruby benchmark.rb [PATH_TO_YOUR_FACEBOOK_ARCHIVE]` before making a pull request. Changes that significantly slow this project may be rejected

**Enjoy!**