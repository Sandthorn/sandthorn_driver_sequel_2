[![Code Climate](https://codeclimate.com/github/Sandthorn/sandthorn_driver_sequel.png)](https://codeclimate.com/github/Sandthorn/sandthorn_driver_sequel)

# Sandthorn Sequel-driver 2

A SQL database driver for [Sandthorn](https://github.com/Sandthorn/sandthorn), made with [Sequel](http://sequel.jeremyevans.net/).

This sequel driver is a rewrite from [sandthorn_driver_sequel](https://github.com/Sandthorn/sandthorn_driver_sequel) and its purpous is to speed up batch imports. 

It has removed the aggregate table and store all aggregate and event data in the events table. Its now possible to output the event data to file and import it to the database after a batch import with the COPY command. This speeds up the import of larger dataset by a magnitude of alot. A note is that the aggregate_version checks has been removed and the user has to make sure that no other write of events are written during batch import.

## Installation

Add this line to your application's Gemfile:

    gem 'sandthorn_driver_sequel_2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sandthorn_driver_sequel_2

## Usage

Its possible to setup the EventStore with the events_file_path option, this will make the EventStore output all its events to this file path.

    SandthornDriverSequel2.driver_from_url(url: event_store_url, events_file_path: "../events.csv")

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
