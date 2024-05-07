# Common Utils

Common Utils is a collection of utility functions for common tasks, including TOCExtractor.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'common_utils', '~> 0.1.0', github: 'flexiple-buildd/common_utils'
```

And then execute

```bash
bundle install
```

## How to Use

Require using

```ruby
require 'common_utils/toc_extractor'
```

Use by passing data as string

```ruby
result = TOCExtractor.extract_toc_from_string(YOUR_DATA)
```

Access toc and content using result[:table_of_contents] and result[:content]
