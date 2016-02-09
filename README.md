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
```

Querify will then pickup `:page` and `:per_page` from the request's params hash to automatically control which page is returned & the number of results to return.

To access a particular page of results, pass the `:page` parameter in your URL:

```ruby
www.example.com/posts?page=5&per_page=10
```

If omitted, `:page` is defaulted 1, and `:per_page` is defaulted to 20.

### Pagination Headers Returned

Whenever pagination is used, Querify adds headers for communicating pagination metadata to the client:

```
X-Current-Page: 10
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
