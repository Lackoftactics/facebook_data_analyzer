# facebook_data_analyzer

Facebook data analyzer as seen on [I analyzed my facebook data and it's story of shyness, loneliness, and change](https://medium.com/@przemek_/i-analyzed-my-facebook-data-and-its-story-of-shyness-loneliness-and-change-7f4e0ec3a952)

Analyze facebook copy of your data. Download zip file from facebook and get info about friends ranking by message, vocabulary,  contacts, friends added statistics and more.

# What's inside

* Ranking of friends by messages (number of messages sent, who sent more, how many words, characters in conversation)
* Your most used words in conversations, the most frequent words from english language and also polish (my native language) are deleted. So you get quite good and interesting results
* Your overall statistics of messaging: total number of messages, words, characters, unique words
* How many messages were sent by period: month, week, year, hour. So you can easily get what type of writer you are: night owl vs. early bird. Find your most busy messaging days
* How your history of making friends looked like? Breaked down by month, year, weekend vs. working day,

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
9. Run `bin/analyze_facebook_data -c path_to_catalog_with_copy_of_facebook_data` in my case this command looked like: `bin/analyze_facebook_data -c /Users/przemyslawmroczek/Downloads/facebook-przemekmroczek90/`
10. You will see the script running and analyzing your conversations. At the end you will see it generated new excel file `facebook_analysis.xlsx`, `facebook_analysis.html`

Optional:
If the `DEBUG` environment variable is present, messages are getting converted as json for speed improvement.

```bash
bin/facebook_data_analyzer -v -c <path_to_catalog_with_copy_of_facebook_data>

Parsing Messages    |Time: 00:00:01 | =======| Time: 00:00:01
Analyzing Messages  |Time: 00:00:04 | =======| Time: 00:00:04
= Export facebook_analysis.xlsx
= Export facebook_analysis.html
```

## Minimal Command
```bash
bin/facebook_data_analyzer -c <path_to_catalog_with_copy_of_facebook_data>
```

## Available Options
```bash
bin/facebook_data_analyzer --help
```

```bash
FacebookDataAnalyzer
    -c example/facebook-monaleigh,   set directory to facebook export
        --catalog
    -f, --filename facebook_analysis set the name of the generated files
    -p, --[no-]parallel              use parallel processing if set
    -h, --[no-]html                  export html when set
    -v, --[no-]verbose               when set displays additional information
    -b, --[no-]benchmark             only runs the benchmark if set
        --help                       Show this message
    -V, --version                    Print version
```

## Default values
```bash
catalog         default: 'example/facebook-monaleigh'
filename        default: 'facebook_analysis'
parallel        default: true
html            default: true
verbose         default: false
benchmark       default: false
```

# Contributing

Please consider running your changes with
```bash
bin/facebook_data_analyzer --benchmark
```
before making a pull request. Changes that significantly slow this project may be rejected

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Testing

To run rspec tests in local environment, create `.env` file, based on `.env.example`.
Replace the path inside of `.env.example` with your local path. Run: `bundle install`, `rspec .`.

**Enjoy!**
