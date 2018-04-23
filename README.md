# facebook_data_analyzer

### TODO (northcott-j) (partial refactor is finished)
- Run in Parallel
    - Process each Analyzeable at the same time
    - Process each file at the same time (with Queue)
- Double check numbers (word counts are off)
- Merge in test suite when available
- Add new sheets with more info and insights
- self.parse should return an Object not a Hash

### Update on Performance
Current bottlenecks (in order of % runtime)
- Analyzeable.count   (22%)
- Analyzeable.group   (20%)
- DateTime.parse      (18%)
- doc.at_css(.thread) (11%)

Even with the bottlenecks, speed is now equivalent to the original version. The future version that uses the Parallel library should increase speed to the point where the above slowdowns are negligible.  

Facebook data analyzer as seen on [I analyzed my facebook data and it's story of shyness, loneliness, and change](https://medium.com/@przemek_/i-analyzed-my-facebook-data-and-its-story-of-shyness-loneliness-and-change-7f4e0ec3a952)

**HELP ME OUT!! I am promoting on PRODUCT HUNT. Upvote if you like the project [Product hunt upvote](https://www.producthunt.com/posts/facebook-data-analyzer)**

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

# What's inside

* Ranking of friends by messages (number of messages sent, who sent more, how many words, characters in conversation)
* Your most used words in conversations, the most frequent words from english language and also polish (my native language) are deleted. So you get quite good and interesting results
* Your overall statistics of messaging: total number of messages, words, characters, unique words
* How many messages were sent by period: month, week, year, hour. So you can easily get what type of writer you are: night owl vs. early bird. Find your most busy messaging days
* How your history of making friends looked like? Breaked down by month, year, weekend vs. working day,

** Enjoy! **



# Sorry for code quality, it was proof of concept. It will be refactored in the future.
