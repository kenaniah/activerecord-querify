# Querify

[![Gem Version](https://badge.fury.io/rb/querify.svg)](https://badge.fury.io/rb/querify) [![Circle CI](https://circleci.com/gh/kenaniah/querify.svg?style=shield&circle-token=6f2bd9feb73540b3f8cbbbc57e5ea0156a5625bc)](https://circleci.com/gh/kenaniah/querify) [![Dependency Status](https://gemnasium.com/spidrtech/querify.svg)](https://gemnasium.com/spidrtech/querify) [![Code Climate](https://codeclimate.com/github/kenaniah/querify/badges/gpa.svg)](https://codeclimate.com/github/kenaniah/querify)

## Overview

Querify provides an easy interface for manipulating Active Record queries given a hash of parameters. It extends Active Record classes to provide:

 * `#querify` - where clauses based on a hash of parameters
 * `#paginate` - automatic and highly configurable pagination
 * `#sortable` - order by clauses based on a hash of parameters

Querify was designed to by query string friendly, and making pagination, sorting, and filtering based on URL parameters trivial.

## Getting Started

In **Rails 4**, add this to your Gemfile and run the `bundle install` command:

```ruby
gem 'querify'
```

## Simple Pagination

Easily paginate the results of an Active Record query from the parameters hash. Just call `#paginate` anywhere inside of your query:

```ruby
Post.paginate
Post.where(author_id: 1).paginate
Post.first.comments.paginate

# Overridding options
Post.first.comments.paginate(min_per_page: 1, max_per_page: 10, per_page: 5) 
# the above allows the client to request between 1 - 10 results per page, returning 5 results per page by default
```

Querify will then pickup `:page` and `:per_page` from the request's params hash to automatically control which page is returned & the number of results to return.

To access a particular page of results, pass the `:page` parameter in your URL:

```ruby
www.example.com/posts?page=5&per_page=10
```

If omitted, `:page` is defaulted 1, and `:per_page` is defaulted to 20.

### Pagination Header Metadata

Whenever pagination is used, Querify adds headers for communicating pagination metadata to the client:

```
X-Current-Page: 5
X-Per-Page: 10
```

Recordset totals can be requested by additionally passing the `:page_total_stats` param in the URL:

```ruby
www.example.com/posts?page=4&page_total_stats=1
```

Assuming that there are 291 posts total, the following headers would be returned:

```
X-Current-Page: 4
X-Per-Page: 20
X-Total-Pages: 15
X-Total-Results: 291
```

As using `:page_total_stats` runs a count query, it is recommended to add it to the first request only.

### Config Options

To ensure that clients do not abuse the `:per_page` URL param, we provide the following configuration options for pagination:

 * `:per_page` - the default number of results to be returned per page (20 when not specified)
 * `:min_per_page` - the minimum number of results to be returned per page (also defaults to 20)
 * `:max_per_page` - the maximum number of results to be returned per page (defaults to 100)

These may be set in a config block:

```ruby
Querify.configure do |config|
  config.per_page = 25
  config.min_per_page = 5
  config.max_per_page = 50
end
```

Or in a Rails initializer:

```ruby
Rails.application.config.querify.per_page = 25
Rails.application.config.querify.min_per_page = 5
Rails.application.config.querify.max_per_page = 50
```

#### `config.per_page`

This option sets the default number of results to be returned in the event that `:per_page` is not specified in the URL

#### `config.min_per_page`

It is usually a good idea to constrian the number of results to be returned per page. This option ensures that the `:per_page` param is adjusted to meet this minimum. Setting this to `0` effectively disables the minimum. 

#### `config.max_per_page`

Determines the maximum number of results that can be requested per page. This option ensures that the `:per_page` param is adjusted to meet this maximum. Setting this to `nil` effectively disables the maximum.

### Disabling Pagination

Pagination may be disabled for a single request when the following conditions are met:

 * `per_page=0` is passed in the URL
 * `:max_per_page` was set to `nil`

### Detecting Pagination

Because pagination may be dynamically disabled following the method above, you may ask if any query has been paginted by using the `#paginated?` method:

```ruby
a = Post.all
a.paginated? #=> false

b = Post.all.paginated
b.paginated? #=> true (unless :per_page == 0 and :max_per_page == nil)
```

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
