# Rails Practice

This project is dedicated to my personal practice with Ruby on Rails.
Each example in this project should include a description and link in the readme or any associated docs.

If anyone else is viewing this repo for reference and would like to see any topics or examples covered,
feel free to create an issue about it for me to tackle, or create a PR with the given example!

# 3, 2, 1, Go!

### ActiveRecord

Everyone knows that ActiveRecord is an incredibly powerful ORM, but anyone who's used ActiveRecord also knows
that it's most powerful feature is it's associations' abilities (`belongs_to`, `has_many`, etc.).
Here's the skinny on how those work under the rails hood:

Whenever you define an association on a Rails `ActiveRecord::Base` model, Rails will build an instance of that
association and add it to a list of the Model's associations. Each of these associations defines how the associated
entity(ies) can be found (fetching from cache, executing SQL on DB, etc.). To view all the associations that a rails
model has, you can use the `reflect_on_all_associations` class method as follows:

```ruby
Car.reflect_on_all_associations
# => [#<ActiveRecord::Reflection::BelongsToReflection:0x007fe040117268 @name=:automaker, @scope=nil, @options={},
#     @active_record=Car(id: integer, name: string, year: integer, created_at: datetime, updated_at: datetime, automaker_id: integer),
#     @klass=Automaker(id: integer, name: string, year_founded: integer, created_at: datetime, updated_at: datetime),
#     @plural_name="automakers", @automatic_inverse_of=false, @type=nil, @foreign_type="automaker_type", @constructable=true,
#     @association_scope_cache={}, @scope_lock=#<Thread::Mutex:0x007fe040117088>, @class_name="Automaker",
#     @foreign_key="automaker_id">]
```

As you can see our `Car` model in this instance has one association. A BelongsToAssociation to the `Automaker`
model, if you look closely at `@name`. I am still slightly confused about reflections in Rails,
so I won't get into those here, but take the snippet above as a `Car` model that has one
association (a Belongs To) on it.

If you're wondering how Rails exposes dynamically named methods (like `automaker` or `user` and `posts` in a general
belongs_to/has_many association), they do so through some complex metaprogramming. Essentially
each for each association rails has a `define_accessors` method that is called and given a model name.
This method will create a new blank Ruby module and add readers and writers for these associations to the module.
This process, for instance, with a `Car` model that has a belongs to relationship to an `Automaker` model would
produce the following module:

```ruby
module SomeModule
  def automaker(*args)
    association(:automaker).reader(*args)
  end
  
  def automaker=(value)
    association(:automaker).writer(value)
  end
end
```

This module is then simply `include`d in the `Car` model (behind the scenes) to expose those two methods to all instances
of the `Car` class. Easily allowing us to do something like:

```ruby
automaker = Automaker.create(name: 'Ford')
car = Car.create(name: 'Focus', automaker: automaker)

car.automaker
# => #<Automaker id: X, name: "Ford", created_at: "2018-01-20 02:02:47", updated_at: "2018-01-20 02:02:47"> 
# or 
toyota = Automaker.create(name: 'Toyota')
car = Car.create(name: 'Corolla')
car.automaker =  toyota
car.automaker
# => #<Automaker id: X, name: "Toyota", created_at: "2018-01-20 02:02:47", updated_at: "2018-01-20 02:02:47">
```

An example of the underlying logic that is used for a basic rails belongs_to association accessor, can be found
in this [`_automaker` method]() (with [specs]()!).

##### Belongs To

The `belongs_to` relationship is how you associate a given model object with another
in an ownership type of relationship. In our example we have an Automaker
model and a Car model. The Car model has a `belongs_to` relationship to the
Automaker model. This allows us to call `.automaker` on any instance of a `Car` and get the
associated `Automaker` instance.

To define a belongs_to relationship, simple add:

```ruby
belongs_to :other_model_name
```

in your ActiveRecord model. After added this, 6 additional methods will be exposed to the class:

_example for a `belongs_to :automaker`_

```ruby
automaker
automaker=(value)
build_automaker(attributes = {})
create_automaker(attributes = {})
create_automaker!(attributes = {})
reload_automaker
```

These allow you to easily get, set, and create Automakers associated to the current instance of your model. For example:

```ruby
class Car < ApplicationRecord
  belongs_to :automaker
end


car = Car.create(name: 'F-150')
car.create_automaker(name: 'Ford', year_founded: 1895)
car.automaker
# => #<Automaker id: 2, name: "Ford", year_founded: 1895, created_at: "2018-01-20 02:02:47", updated_at: "2018-01-20 02:02:47"> 
```

**Notes about belongs_to**

- To persist a belongs relationship on a model (ie. setting the associated_model_id attribute), that foreign key
column must exist in the database. This is as easy as creating a migration that does something like:
    - `add_reference :cars, :automaker`
- The following are a list of extra options that can be passed to belongs_to (`:autosave, :class_name, :counter_cache,
:dependent, :foreign_key, :primary_key, :inverse_of, :polymorphic, :touch, :validate, :optional`)

**`:class_name`**

This options allows you to specify a class name that the belongs_to association actual maps to
with a different accessor name. Example:

```ruby
class Car < ApplicationRecord
  belongs_to :automotive_company, class_name: 'Automaker'
end
```

An RSpec test that would pass & verify behavior:

```ruby
it 'belongs to a automotive_company' do
  company = Automaker.create(name: 'Ford', year_founded: 1805)
  subject = Car.create(name: 'Focus', year: 2015, automotive_company: company)

  expect(subject.automotive_company).to eq(company)
  expect(subject.automotive_company.class).to eq(Automaker)
end
```

_Note: To get this to work the foreign key database column in `Car` must be correct. It should map to the name
of the association. In this case, the cars table should have a column `automotive_company_id`._

- For more information about belongs_to: [Belongs To - Rails Guides](http://guides.rubyonrails.org/association_basics.html#belongs-to-association-reference)
- Model Code from this example [here]()
- Specs for this example [here]()
- Migrations for this example [here]()