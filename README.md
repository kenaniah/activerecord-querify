# Querify

[![Gem Version](https://badge.fury.io/rb/querify.svg)](https://badge.fury.io/rb/querify) [![Circle CI](https://circleci.com/gh/kenaniah/querify.svg?style=shield&circle-token=6f2bd9feb73540b3f8cbbbc57e5ea0156a5625bc)](https://circleci.com/gh/kenaniah/querify) [![Dependency Status](https://gemnasium.com/spidrtech/querify.svg)](https://gemnasium.com/spidrtech/querify) [![Code Climate](https://codeclimate.com/github/kenaniah/querify/badges/gpa.svg)](https://codeclimate.com/github/kenaniah/querify)

## Overview

Querify provides an easy interface for manipulating Active Record queries given a hash of parameters. It extends Active Record classes to provide:

| Active Record Method | Purpose |
|----------------------|---------|
| [`#paginate`](#automatic-pagination) | automatic and highly configurable pagination |
| [`#sortable`](#automatic-sorting) | orders the query based on a hash of parameters |
| `#querify` | where clauses based on a hash of parameters |
| [`#sortable!`](#querifyinvaliddirection) | like `#sortable`, but throws exceptions instead of silently ignoring them |
| `#querify!` | like `#querify`, but throws exceptions instead of silently ignoring them |

Querify was designed to be query string friendly, making pagination, sorting, and filtering based on URL parameters trivial.

## Getting Started

In **Rails 4**, add this to your Gemfile and run the `bundle install` command:

```ruby
gem 'querify'
```

To make a query automatically paginate, sort, and dynamically filter based on query string parameters, just add all 3 methods to a query:

```ruby
Post.find(params[:post_id]).comments.paginate.sortable.querify.order(id: :desc)
```

And then manipulate your query via URL params:

```
www.example.com/posts?page=2&sort[created_at]=desc&where[author_id][eq]=1&where[created_at][gt]=2+days+ago
```

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

Querify will then pickup `:page` and `:per_page` from the request's params hash to automatically control which page is returned & the number of results to return.

To access a particular page of results, pass the `:page` parameter in your URL:

```ruby
www.example.com/posts?page=5&per_page=10
```

If omitted, `:page` is defaulted to 1, and `:per_page` is defaulted to 20.

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

| Config Option | Default Value | Description |
|---------------|---------|-------------|
| `:per_page` | 20 | the default number of results to be returned per page |
| `:min_per_page` | 20 | the minimum number of results to be returned per page |
| `:max_per_page` | 100 | the maximum number of results to be returned per page |

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

##### `config.per_page`

This option sets the default number of results to be returned in the event that `:per_page` is not specified in the URL

##### `config.min_per_page`

It is usually a good idea to constrian the number of results to be returned per page. This option ensures that the `:per_page` param is adjusted to meet this minimum. Setting this to `0` effectively disables the minimum.

##### `config.max_per_page`

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
b.paginated? #=> true

c = Post.all.paginated(max_per_page: nil)
c.paginated? #=> false when :per_page == 0, true otherwise
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

**Warning:** We make no guarantee that the columns sorted by are actually columns of the query. You may need to catch invalid statement exceptions when using this method.

### Accepted Sort Directions

| Param Value | Sort Direction |
|-------------|----------|
| `asc` | ASC |
| `desc` | DESC |
| `:asc` | ASC |
| `:desc` | DESC |
| `:ascnf` | ASC NULLS FIRST |
| `:ascnl` | ASC NULLS LAST |
| `:descnf` | DESC NULLS FIRST |
| `:descnl` | DESC NULLS LAST |

#### `Querify::InvalidDirection`

When an invalid direction is passed in to a sort param, `Querify::InvalidDirection` is thrown.

When using the `#sortable` method, this exception is silently caught, and the offending sort param is silently ignored.

To force this exception to bubble up, use the `#sortable!` method instead.

#### `Querify::InvalidSortColumn`

This exception is thrown when sortable is called with a whitelist and a sort is requested for a column that is not in the whitelist.

When using the `#sortable` method, this exception is silently caught, and the offending sort param is silently ignored.

To force this exception to bubble up, use the `#sortable!` method instead.

## Column Security

To ensure that clients do not pass columns that are non-existent or restricted, you can provide a hash of columns & types to whitelist by using the `columns:` hash and enabling the `only:` key.

```ruby
Post.sortable columns: {id: :integer, name: :text}, only: true # silently ignores columns that aren't whitelisted
Post.querify! columns: {id: :integer, name: :text}, only: true # throws an exception for columns that aren't whitelisted
```

`columns:` takes a hash where the keys represent column names and the values represent the Active Record type of the column.

`only:` causes the function to disallow any columns that aren't explicitly listed in the `columns:` hash.

## Bugs?

If you find a bug please [add an issue on GitHub](https://github.com/kenaniah/querify/issues) or fork the project and send a pull request. Feature requests are also welcome.
