# Querify

[![Gem Version](https://badge.fury.io/rb/querify.svg)](https://badge.fury.io/rb/querify) [![Circle CI](https://circleci.com/gh/kenaniah/querify.svg?style=shield&circle-token=6f2bd9feb73540b3f8cbbbc57e5ea0156a5625bc)](https://circleci.com/gh/kenaniah/querify) [![Dependency Status](https://gemnasium.com/spidrtech/querify.svg)](https://gemnasium.com/spidrtech/querify) [![Code Climate](https://codeclimate.com/github/kenaniah/querify/badges/gpa.svg)](https://codeclimate.com/github/kenaniah/querify)

## Overview

Querify provides an easy interface for querying ActiveRecord data given a hash of parameters. It also allows you to specify configuration options to set limits to paginated requests.

## Getting Started

In **Rails 4**, add this to your Gemfile and run the `bundle install` command:

```ruby
gem 'querify'
```

## About Pagination

Easily paginate the results of an ActiveRecord query from the parameters hash. A simple query string would look like:

```ruby
www.example.com/results?per_page=20
```

To access a particular page of results, pass in the page parameter.

```ruby
www.example.com/results?per_page=20?page=10
```

Also, return a HTTP header with page stats by adding the following parameter to the query string:
```ruby
page_stats=1
```

This will return the current page and the total number of pages.

## About Sorting

Querify also takes sort and order options from the parameters hash. For example:

```ruby
www.example.com/results?sort=user_id,email?order=ASC,DESC
```

This query will return results sorted first by ascending user_id and then by descending email.


## Configuration Options

You can configure several options in the query string to regulate the number of results returned per page.

```ruby
# In config/initializers/querify.rb:
Querify.configure do |config|
    config.per_page = 25
    config.min_per_page = 10
    config.max_per_page = 50
end
```

To prevent overly large queries from being returned, the max_per_page option is only accessible to the website administrator. The per_page parameter cannot override the max_per_page config option.


## Examples

Add the paginate method to your controller to enforce pagination.

```ruby
class UsersController

	def index
			render json:
				@user
					.posts
						.paginate
						.sortable
						.includes(:tags, :user)
	end
end

```
