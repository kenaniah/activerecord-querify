# Querify

[![Gem Version](https://badge.fury.io/rb/activerecord-querify.svg)](https://badge.fury.io/rb/activerecord-querify) [![Circle CI](https://circleci.com/gh/kenaniah/activerecord-querify.svg?style=shield&circle-token=6f2bd9feb73540b3f8cbbbc57e5ea0156a5625bc)](https://circleci.com/gh/kenaniah/activerecord-querify) [![Dependency Status](https://gemnasium.com/kenaniah/activerecord-querify.svg)](https://gemnasium.com/kenaniah/activerecord-querify) [![Code Climate](https://codeclimate.com/github/kenaniah/activerecord-querify/badges/gpa.svg)](https://codeclimate.com/github/kenaniah/activerecord-querify)

## Overview

Querify provides an easy interface for manipulating Active Record queries based on a hash of parameters or query string arguments. It extends Active Record classes to provide:

| Active Record Method | Purpose | Manages |
|----------------------|---------| ------- |
| [`#paginate`](#automatic-pagination) | automatic and highly configurable pagination | `LIMIT` / `OFFSET` |
| [`#sortable`](#automatic-sorting) | orders the query based on a hash of parameters | `ORDER BY` |
| [`#sortable!`](#automatic-sorting) | like `#sortable`, but throws exceptions instead of silently ignoring them | `ORDER BY` |
| [`#filterable`](#automatic-filtering) | filtering clauses based on a hash of parameters | `WHERE` / `HAVING` |
| [`#filterable!`](#automatic-filtering) | like `#filterable`, but throws exceptions instead of silently ignoring them | `WHERE` / `HAVING` |


## Getting Started

In **Rails 4+**, add this to your Gemfile and run the `bundle install` command:

```ruby
gem 'activerecord-querify'
```

To make a query automatically paginate, sort, and dynamically filter based on query string parameters, just add all 3 methods to a query:

```ruby
Post.first.comments.paginate.sortable.filterable.order(id: :desc)
```

And then manipulate your query via URL params:

```
www.example.com/posts?page=2&sort[created_at]=desc&where[author_id][:eq]=1&where[created_at][:gt]=2+days+ago
```

## Live Examples

< Link to example rails app goes here >

## Automatic Pagination

Easily paginate the results of an Active Record query from the parameters hash. Just call `#paginate` anywhere inside of your query:

```ruby
Post.paginate
Post.where(author_id: 1).paginate
Post.first.comments.paginate

# Overriding options
Post.first.comments.paginate(min_per_page: 1, max_per_page: 10, per_page: 5)
# the above allows the client to request between 1 - 10 results per page, returning 5 results per page by default
```

Querify will then pickup `?page` and `?per_page` from the request's params hash to automatically control which page is returned & the number of results to return.

To access a particular page of results, pass the `?page` parameter in your URL:

```ruby
www.example.com/posts?page=5&per_page=10
```

If omitted, `?page` is defaulted to 1, and `?per_page` is defaulted to the `:per_page` config option.

### Pagination Header Metadata

Whenever pagination is used, Querify adds headers for communicating pagination metadata to the client:

```
X-Current-Page: 5
X-Per-Page: 10
```

Recordset totals can be requested by additionally passing the `?page_total_stats` param in the URL:

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

Because `?page_total_stats` runs a count query, it is recommended to use it only on the first request.

### Config Options / Preventing Abuse

To ensure that clients do not abuse the `?per_page` URL param, we provide the following configuration options for pagination:

| Config Option | Default Value | Description |
|---------------|---------|-------------|
| `:per_page` | 20 | the default number of results to be returned per page |
| `:min_per_page` | 20 | the minimum number of results to be returned per page |
| `:max_per_page` | 100 | the maximum number of results to be returned per page |

These may be set in a config block:

```ruby
ActiveRecord::Querify.configure do |config|
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

And also overridden at call time:

```ruby
Post.first.paginate(per_page: 25, min_per_page: 5, max_per_page: 50)
```

##### `config.per_page`

This option sets the default number of results to be returned in the event that `?per_page` is not specified in the URL

##### `config.min_per_page`

It is usually a good idea to constrian the number of results to be returned per page. This option ensures that the `?per_page` param is adjusted to meet this minimum. Setting this to `0` effectively disables the minimum.

##### `config.max_per_page`

Determines the maximum number of results that can be requested per page. This option ensures that the `?per_page` param is adjusted to meet this maximum. Setting this to `nil` effectively disables the maximum.

### Optionally Bypassing Pagination

Pagination may be bypassed for a single request if allowed by a query's config. Here's how:

 * `?per_page=0` must be passed in the URL
 * `:max_per_page` option must be set to `nil` in config or at call time

### Detecting Pagination

Because pagination may be dynamically disabled following the method above, you may ask if any query has been paginated by using the `#paginated?` method:

```ruby
a = Post.all
a.paginated? #=> false

b = Post.all.paginated
b.paginated? #=> true

c = Post.all.paginate(max_per_page: nil)
c.paginated? #=> false when ?per_page=0, true otherwise
```

## Automatic Sorting

Sorts your Active Record query from the parameters hash. Just call `#sortable` anywhere inside of your query:

```ruby
Post.sortable
Post.where(author_id: 1).sortable
Post.first.comments.sortable.order(id: :desc) # always a good idea to have a default sort
```

Given the url:

```ruby
www.example.com/results?sort[authors.name]=desc&sort[id]=desc
```

The query would be sorted by `"authors.name" DESC, "id" DESC`.

Sortable expects the parameter hash in the format:

```
sort[<column_name>]=<direction>
```

### Available Sort Directions

| Param Value | SQL Direction |
|-------------|----------|
| `asc` | ASC |
| `desc` | DESC |
| `:asc` | ASC |
| `:desc` | DESC |
| `:ascnf` | ASC NULLS FIRST |
| `:ascnl` | ASC NULLS LAST |
| `:descnf` | DESC NULLS FIRST |
| `:descnl` | DESC NULLS LAST |

### Possible Sorting Exceptions

#### `ActiveRecord::Querify::InvalidDirection`

When an invalid direction is passed in a sort param, `ActiveRecord::Querify::InvalidDirection` is thrown.

When using the `#sortable` method, this exception is silently caught, and the offending sort param is silently ignored.

To force this exception to bubble up, use the `#sortable!` method instead.

#### `ActiveRecord::Querify::InvalidSortColumn`

This exception is thrown when a sort is requested for a column that is not part of the query or not part of the whitelist.

When using the `#sortable` method, this exception is silently caught, and the offending sort param is silently ignored.

To force this exception to bubble up, use the `#sortable!` method instead.

## Automatic Filtering

Querify allows you to filter an Active Record query using both existing columns and SQL column expressions. 

## Column Security / Whitelisting

To ensure that clients do not pass columns that are non-existent or restricted, you can provide a hash of columns & types to whitelist by using the `columns:` hash and enabling the `only:` key.

```ruby
Post.sortable columns: {id: :integer, name: :text}, only: true # silently ignores columns that aren't whitelisted
Post.filterable! columns: {id: :integer, name: :text}, only: true # throws an exception for columns that aren't whitelisted
```

`columns:` takes a hash where the keys represent column names and the values represent the Active Record type of the column.

`only:` causes the function to disallow any columns that aren't explicitly listed in the `columns:` hash.

## Bugs? Feature Requests?

If you find a bug or have a feature request, please [add an issue on GitHub](https://github.com/kenaniah/activerecord-querify/issues) or fork the project and send a pull request.
