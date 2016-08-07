# 538 Tweet Bot

[![Build Status](https://travis-ci.org/daguar/538-election-forecast-bot.svg?branch=master)](https://travis-ci.org/daguar/538-election-forecast-bot)

A bot that tweets any time the [538 Election Model](https://projects.fivethirtyeight.com/2016-election-forecast/) is updated.

The live bot lives at: [https://twitter.com/538forecastbot](https://twitter.com/538forecastbot)

## Local development

- `git clone` the repo
- Install the correct version of Ruby (see Gemfile) with rbenv or rvm
- Run `bundle install` to install dependencies
- Run tests with `bin/rspec spec`

## Deploying

This currently runs on Heroku and uses their scheduler to check for updates every 10 minutes. It does this by running the script `bin/tweet_forecast_if_new`.

## Contact

Feel free to ping me on Twitter at [https://twitter.com/allafarce](https://twitter.com/allafarce)

## Copyright & License

Copyright 2016 Dave Guarino — MIT License
