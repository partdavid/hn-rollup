# Hn::Rollup

Hierachical notes - rollup. This gem provides tools and utilities to
take hierachical notes and provides schemaless automatic rollups. It's
intended to be particularly useful for cases like:

* Rough project estimation with free-ish form cost and effort fields
  for various notes
* Smart summarization of freeform records of work performed

Examples of things you could build with `hn`:

* A project planning system
* A work tracker
* A lightweight ticket system

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hn-rollup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hn-rollup

## Usage

### Note Document

Center to the `hn` system is the notes document, which is simply a
tree of notes, starting with a top-level root note with optional
children. Each child can have children, and so on, all the way until
you reach the leaf notes. Within each note, you can automatically
view the rollup of the note and all of its children.

Notes are "lightly-structured", with the following "data model". These
are the only special fields in `hn`:

* **hn_info** - Various internal audit info, like history, usernames,
  etc. This should be mostly opaque and rarely displayed in the
  "normal" use of **hn**, but future tools can use this for shared
  environments and more extended uses. As a design consideration, lack
  of **hn_audit_info** should never cause a functionality difference
  in the operation of the "main" (non-administrative) tools. This will
  also be `hn`'s extension mechanism for "enterprise" features if it
  should ever require one; for example, for ACLs, group ownership,
  that kind of thing. However, if you are building an `hn`-based tool
  to do business logic on note documents (e.g., send email of note
  "assignment" use your own fields).
* **title** - The short title or summary of the note. This can be (and
  often is) the entirety of the note. The `hn` tools are designed for
  the most common ease-of-use case where you want to add like five
  notes using a CLI or text input format and then work with them.
* **children** - The array of child note documents.

The following is the "minimal" note document, consisting of nothing
other than the title:


```json
{
  "title": "Reinforce deck"
}
```

Logically, this is equivalent to:

```json
{
  "title": "Reinforce deck"
  "hn_info": { ... }
  "children": [ ]
}
```

Any other fields are displayed or rolled up according to their values,
not their names. Although fields are never typed, values always are;
they came in two flavors (note that the `hn` tools here implement a
JSON-centric view of notes; notes must always be exactly representable
with JSON).

Field values have "units", which describe how to display and roll up
the data. All the "magic" of `hn` is captured in these types. Note
that units are often parsed out of a string value, and that the string
value is always *left alone*.

### Dimensionless (Raw JSON values)

When a note field has a simple JSON value, the unit is the same as
the JSON type. Below, you'll find out the rules for displaying and
rolling up units:

* `null`
* `false`
* `true`
* `string`
* `number`

Note that `string` values here refers to string values that are "left"
after all the possible units are checked. For example, titles are
usually `string` values, which means that when rolled up, the parent's
value overwrites all childrens'. However, if one title is `"2d"`, meaning
two days, that's actually an interval, meaning the children's interval values are
added to the parents' interval values. This is only possible with a
dimensioned value.

### Dimensioned

A dimensioned value has units which dictate how that value is displayed
and rolled up. Remember, in `hn`, it's *values* that have types, not
fields.

Alternate representation

### Example

Consider the following project, represented as a note (`hn_info` not shown):

```json
{ "title": "Reinforce deck",
  "children": [
    { "title": "House anchors",
      "cost": "$32" },
    { "title": "Make replacement railing supports",
      "cost": "$85",
      "effort": "2d" }
  ]}
```

When we run `hn rollup --keep-children` on our JSON file, it produces the following
result (called a rollup or output document--and note; it is **not**
itself suitable as a notes document or input document. Repeated
aggregations are not idempotent):

```json
{ "title": "Reinforce deck",
  "cost": "$107",
  "effort": "2d",
  "children": [
    { "title": "House anchors",
      "cost": "$32" },
    { "title": "Make replacement railing supports",
      "cost": "$85",
      "effort": "2d" }
  ]}
```

Notice how `hn` rolled up each field:

**title**: Go through each child, aggregating the simple string values
`House anchors` and `Make replacement railing supports` by precedence:
children replace a current null value but are otherwise dropped,
meaning the aggregate value for the children is `House anchors`. Then,
aggregate this result with the parent. As a simple string value, this
is aggregated by precedence: a parent value has higher precedence than
the child value, so the child value is dropped and the parent value of
`Reinforce deck` remains unchanged.

**cost**: Go through each child, aggregating the values. The child
with `"cost": "$32"` is recognized as a dollar value, and dollars
aggregate by addition. Therefore, the current `cost` value is (in
alternate representation): `{ "dollars": 32 }`.  Then the next
sibling's `cost` value (if it exists) is aggregated by addition. The
new value is `{ "dollars": 107 }`. Now, the `cost` value of the parent
is considered. There is no `cost` field on the parent, so the new one
takes precedence, and the value of `{ "dollars": 107 }` is used. We
can reduce that back to simple representation; i.e., `"cost": "$107"`
so we do.

**effort**: Go through each child, aggregating the value of
`"effort"`. There's only one child with a value, `"2d"`, which is an
interval. Its alternate representation is `{ "interval (seconds)":
172800 }` (maybe?), but since nothing else has a value, it's used and
is reduced back to `"2d"`. BTW, an `{ "interval (seconds)": 172801 }` value
would be reduced to `"2d1s"`.

Let's look at what happens if we have a multi-valued field. For
example, maybe we think of `cost` as reflecting both dollars and
labor:

```json
{ "title": "Reinforce deck",
  "children": [
    { "title": "House anchors",
      "cost": "$32" },
    { "title": "Make replacement railing supports",
      "cost": "2d" },
    { "title": "Replacement railing supports lumber",
      "cost": "$85" }
  ]}
```

Running `hn rollup --keep-children` on the document, we get the
following rollup:

```json
{ "title": "Reinforce deck",
  "cost": ["$107", "2d"],
  "children": [
    { "title": "House anchors",
      "cost": "$32" },
    { "title": "Make replacement railing supports",
      "cost": "2d" },
    { "title": "Replacement railing supports lumber",
      "cost": "$85" }
  ]}
```

Note that we have essentially the same information and nothing was
lost: the aggregated values for the `cost` field now contain both
aggregate values. The values are separate because they have different
units; they're not aggregatable. `hn` was able to reduce the multi-valued
field this far; its alternate representation is
`[{ "dollars": 107 }, { "interval (seconds)": 172800 }]`. But because
the peer values for `"dollars"` and `"interval (seconds)"` are not
aggregatable, they are left in the array. This is one way in which
rollups (or output documents) are not the same as notes (or input
documents)--input documents always have only one value for a field.
          
### Storage

Although the canonical form of notes and rollups are defined for tool
usage, this doesn't mean we always have to store them this way. All the
basic CLI tools to start with always use a file on disk which is the
note being operated on (the whole hierarchy). In reality, this is one
possible form of storage; you can see how a document store might be
used instead, or a storage backend could map notes to an RDBMS. Providing
additional backends besides `file` (the default) is a future development
area.

### Units

The following units are supported in the core `hn` units collection,
and more are possible via plugins:

Name: **HN::Unit::Null**
Reduced representation: `null`
Alternate representation: `{ "null": null }`
Sibling aggregation: **drop**: `{ "null": null }` + `*` -> `*`
Parent aggregation: **drop**: `*` + `{ "null": null }` -> `*`

Name: **HN::Unit::Boolean**
Reduced representation: `false` | `true`
Alternate representation: `{ "boolean": true }` | `{ "boolean": false }`
Sibling agregation: **drop**: `{ "boolean": * }` + `{ "boolean": * }` -> `{ "null": null }`
Parent aggregation: **drop**: `{ "boolean": * }` + `{ "boolean": * }` -> `{ "null": null }`

Name: **HN::Unit::Number**
Reduced representation: `0` | `1` | ...
Alternate representation: `{ "number": 0 }`
Sibling aggregation: **add**: `{ "number": 0 }` + `{ "number": 1 }` -> `{ "number": 1 }`
Parent aggregation: **add**:  `{ "number": 0 }` + `{ "number": 1 }` -> `{ "number": 1 }`

Name: **HN::Unit::Dollar**
Reduced representation: `$9` (`9 USD`)
Alternate representation: `{ "dollars": 0 }`
Sibling aggregation: **add**
Parent aggregation: **add** (?)

Name: **HN::Unit::Interval**
Reduced represetation: `2d` | `5m` | `3h30m`
Alternate representation: `{ "interval (seconds)": 180 }`
Sibling aggregation: **add**
Parent aggregation: **add**

Name: **HN::Unit::Period**
Reduced representation: `3/4/2019 - 1/10/2020`
Alternate representation: `{ "period": "2019-03-04 00:00:00Z..2020-01-10 00:00:00Z" }`
Sibling aggregation: **widen**
Parent aggregation: **widen**

Name: **HN::Unit::PeriodStart**
Reduced representation: `start 3/4/2019`
Alternate representation: `{ "period start": "2019-03-04 00:00:00Z" }`
Sibling aggregation: **min**
Parent aggregation: **min**

Name: **HN::Unit::PeriodEnd**
Reduced representation: `end 1/10/2020`
Alternate representation: `{ "period end": "2020-01-20 00:00:00Z" }`
Sibling aggregation: **max**
Parent aggregation: **max**

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake spec` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/hn-rollup.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
