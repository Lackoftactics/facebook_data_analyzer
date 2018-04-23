# facebook_data_analyzer

### TODO (northcott-j) (partial refactor is finished)
- Run in Parallel
    - Only leveraging in Messages currently
- Double check numbers (word counts are off)
- Merge in test suite when available
- Add new sheets with more info and insights

### Update on Performance
Current bottlenecks (in order of % runtime)
- Analyzeable.count   (22%)
- Analyzeable.group   (20%)
- DateTime.parse      (18%)
- doc.at_css(.thread) (11%)

Even with the bottlenecks, speed (without Parallel) is now equivalent to the original version.

Currently, Parallel makes the analysis take longer. I've left the code to support processing Messages using threads, but have disabled it.

### Planned additional analyses 
|                                       Idea                                          |     Difficulty (1-5)
|                                    -----------                                      |          :----:
| Popular words per conversation                                                      | 1
| The top words shared by everyone in the conversation                                | 1
| Who you talk to most across every conversation                                      | 1 
| Analysis of who sends the most multimedia messages (pictures, stickers, gifs, etc.) | 2
| Breakdown of who sends the last message                                             | 3
| Words often used in the last message of a conversation                              | 3
| Timeline of messages (highlighting concurrent conversations)                        | 4
| Friendship velocity (date friended to number of messages sent/received)             | 3
| Strongest friendship (consistent communication)                                     | 2
| Attempt to breakdown messages by gender of recipient                                | 1
| Videos/Pictures with the most comments (+ top words used)                           | 2
| Some kind of breakdown of Security information                                      | 3
| Some kind of analysis of the timeline.html                                          | 3
| Integrate SMS data with messaging stats                                             | 5

## README from forked project -> [here](https://github.com/Lackoftactics/facebook_data_analyzer)
