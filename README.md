# README

Associations make it much easier to perform various operations on the records in your code. There are multiple types of associations available:

One-to-one
One-to-many
Many-to-many
Polymorphic one-to-many
In this article we are going to discuss all of them as well as some options for further customization. The source code is available on GitHub.

One-to-many Associations
To start off, create a new Rails app:

$ rails new rails-relations

A one-to-many association is probably the most common and widely used type. The idea is pretty simple: record A may have many records B and record B belongs to only one record A. For each record B you have to store an id of the record A it belongs to – this id is called a foreign key.

Let’s try it in practice. Suppose, we have a user that may have a bunch of posts. First of all, create the User model:

$ rails g model User name:string
As for the posts table, it has to contain a foreign key and the convention is to name this column after the related table, so in our case that would be user_id (note the singular form):

$ rails g model Post user:references body:text
user:references is a neat way to define a foreign key – it will automatically name the corresponding column user_id and add an index on it. Inside your migration you’ll see something like:

t.references :user, foreign_key: true
Of course, you can also say:

$ rails g model Post user_id:integer:index body:text
Apply your migrations:

$ rails db:migrate
Don’t forget that the models themselves have to be equipped with the special methods to properly establish relations. As long as we used the references keyword when generating migration, the Post model will already have the following line:

belongs_to :user
Still, the User has to be modified manually:

models/user.rb

[...]
has_many :posts
[...]
Note the plural form (“posts“) for the relation’s name. For the belongs_to relation, you use the singular form (“user”).

That wasn’t that hard, was it? Now the relation is established and you can use methods like:

user.posts – references user’s posts
user.posts << post – establishes a new relation between a user and a post
post.user – references an owner of the post
user.posts.build({ }) – instantiates a new post for the user, but doesn’t save it into the database yet. It does populate the user_id attribute on the post. This is similar to saying Post.new({user_id: user.id}).
user.posts.create({ }) – creates a new post and saves it into the database.
post.build_user – same as above, instantiates a new user without saving it
post.create_user – same as above, instantiates and saves the user into the database
Let’s discuss some options that you may set when defining relations. Suppose, for example, that you want the belongs_to relation to be called author, not user:





models/post.rb

[...]
belongs_to :author
[...]
This, however, is not enough, because Rails uses the :author argument to derive the name of the associated model and the foreign key. As long as we don’t have a model called Author, we have to specify the actual name of the class:

models/post.rb

[...]
belongs_to :author, class_name: 'User'
[...]
So far so good, but the posts table doesn’t have an author_id field as well, so we need to redefine the :foreign_key option:

models/post.rb

[...]
belongs_to :author, class_name: 'User', foreign_key: 'user_id'
[...]
Now, inside your console you may do something like:

$ post = Post.new
$ post.create_author
and everything should be working just fine.

Please note that, for the has_many association, there are also :class_name and :foreign_key options available. What’s more, using these options, you can establish a relation where a model references itself as described here.

Another common option that you can set is :dependent, usually for the has_many relation. Why do we need it? Suppose, a user called John has a bunch of posts. Then, out of the blue, John is deleted from the database – well, that happens… But what about his posts? They still have the user_id column set to John’s id, but this record does not exist anymore! These posts are called orphaned records and may lead to various problems, so you probably will want to take care of such a scenario.

The :dependent option accepts the following values:

:destroy – all associated objects will removed one by one (in a separate query). The appropriate callbacks will be run before and after deletion.
:delete_all – all associated objects will be deleted in a single query. No callbacks will be executed.
:nullify – foreign keys for the associated objects will be set to NULL. No callbacks will be executed.
:restrict_with_exception – if there are any associated records, an exception will be raised.
:restrict_with_error – if there are any associated records, an error will be added to the owner (the record you are trying to delete).
So, as you can see, there are many ways to handle this scenario. For this demo I’ll use :destroy:

models/user.rb

[...]
has_many :posts, dependent: :destroy
[...]
What’s interesting is, belongs_to also supports the :dependent option – it may be set to either :destroy or :delete). However, with one-to-many relations I highly discourage you from setting this option.

Another thing worth mentioning is that in Rails 5, by default, you cannot create a record if its parent does not exist. Basically, this means that you can’t do:

Post.create({user_id: nil})
because obviously there is no such user.

This new feature may be disabled for the whole app by tweaking the following initializer file:

config/initializers/active_record_belongs_to_required_by_default.rb

Rails.application.config.active_record.belongs_to_required_by_default = false # default is true
Also you may set the :optional setting for the individual relations:

belongs_to :author, optional: true
One-to-one Associations
With one-to-one relations you are basically saying that a record contains exactly one instance of another model. For example, let’s store user’s address in a separate table called addresses. This table must contain a foreign key which is by default named after the relation:

$ rails g model Address street:string city:string country:string user_id:integer:index
$ rake db:migrate
For the user simply say:

models/user.rb

has_one :address
Having this in place, you may call methods like

user.address – fetches the related address
user.build_address – same as the method provided by belongs_to; instantiates a new address, but does not
save it into the database.
user.create_address – instantiates a new address, and saves it into the database.
The has_one relation allows you to define :class_name, :dependent, :foreign_key, and other options, just like with has_many.

Many-to-many Associations
“Has and Belongs to Many” Association
Many-to-many associations are a bit more complex and can be set up in two ways. First of all, let’s discuss a direct relation, without any intermediate models. It is called “has and belongs to many” or simply “HABTM”.

Suppose, a user can enroll in many different events and an event may contain many users. To achieve this goal, we require a separate table (often called a “join table”) that stores relations between users and events. This table has to have a special name: users_events. Basically, it is just a combination of the two tables’ names that we are establishing relation between.

Firstly, create events:

$ rails g model Event title:string
Now the intermediate table:

$ rails g migration create_events_users user:references event:references
$ rake db:migrate
Note the name of the intermediate table – Rails expects it to be composed of two tables’ names (`events` and `users`). Moreover, the higher-order name (`events`) should be the first one (`events > users`, because letter “e” precedes letter “u”).The last step is to add the has_and_belongs_to_many to both models:

model/user.rb

[...]
has_and_belongs_to_many :events
[...]
model/event.rb

[...]
has_and_belongs_to_many :users
[...]
Now you may call methods like:

user.events
user.events << [event1, event2] – creates relations between a user and a bunch of events
user.events.destroy(event1) – destroys relation between records (the actual records won’t be removed). There is also a delete method that does pretty much same except it does not run callbacks
user.event_ids – a neat method that returns an array of ids from the collection
user.event_ids = [1,2,3] – makes the collection contain only the objects identified by the supplied primary key values.
Note that if the collection initially contained other objects, they will be removed.
user.events.create({}) – creates a new object and adds it to the collection
has_and_belongs_to_many accepts :class_name and :foreign_key options that we’ve already discussed. However, it also supports some other special settings:

:association_foreign_key – by default, Rails uses the relation name to find the foreign key in the intermediate table that is, in turn, used to find the associated object. So, for example, if you say has_and_belongs_to_many :users, the user_id column will be used. However, that’s not always convenient, so the :association_foreign_key can be employed to define a custom column’s name.
:join_table – this option can be used to redefine the name for the intermediate table (that is called users_events in our case).
That’s pretty much it. Still, has_and_belongs_to_many is a pretty rigid way to define many-to-many associations because you can’t work with the relationship model independently. In many cases, you’ll want to store some additional data for each relation or define extra callbacks which cannot be done with HABTM relation. Therefore, I am going to show you another, more convenient, way to solve the same task.

“Has Many Through” Association
Another way to define a many-to-many association is to use the has many through association type. Suppose we have a list of games and, from time to time, competitions on these games are held. Many users may participate in many competitions. Apart from establishing a many-to-many relation between the users and games, we also want to store additional info about each enrollment, like the competition’s category (amateur, semi-pro, pro, etc.)

First of all, create a new Game model:

$ rails g model Game title:string
We also need an intermediate table, but this time with a model:

$ rails g model Enrollment game:references user:references category:string
$ rake db:migrate
For the Enrollment model everything was set up automatically:

models/enrollment.rb

[...]
belongs_to :game
belongs_to :user
[...]
Tweak the two other models:

models/user.rb

[...]
has_many :enrollments
has_many :games, through: :enrollments
[...]
models/game.rb

[...]
has_many :enrollments
has_many :users, through: :enrollments
[...]
Here, we explicitly specify the intermediate model to establish this relation. Now you can work with each enrollment as an independent entity, which is more convenient. Note, that if the name of the source association cannot be automatically inferred from the association’s name, you may utilize the :source option and set its value accordingly.

So, to summarize using has_many :through is preferred over has_and_belongs_to_many, however, in simple cases you may stick with the latter solution.

“Has One Through” Associations
Another interesting association type is the has one through that is somewhat similar to what we’ve seen in the previous section. The idea is that a model is matched with another one through an intermediate model. Suppose a user has a purse and a purse has a payment history. First of all, create the Purse model:

$ rails g model Purse user:references funds:integer
user_id is going to be the foreign key to establish relation between a user and his purse. And now the PaymentHistory model:

$ rails g model PaymentHistory purse:references
$ rake db:migrate
Now tweak models like this:

models/user.rb

has_one :purse
has_one :payment_history, through: :purse
models/purse.rb

belongs_to :user
has_one :payment_history
models/payment_history.rb

belongs_to :purse
This type of relation is rarely used, but sometimes can come in handy.

Polymorphic Associations
Polymorphic associations may save the day in certain scenarios. Despite the scary name, the idea is simple: you have a model that may belong to many different models on a single association. Suppose, you are going to make games and users commentable. Of course, you might have two separate models called UserComment and GameComment but, all in all, comments are very similar except for the fact that they belong to different models. That’s when polymorphic associations come into play.

Create a new Comment model:

$ rails g model Comment body:text commentable_id:integer:index commentable_type:string
Probably, you are already getting the idea. commentable_id is a foreign key to establish relation with other tables. commentable_type, in turn, will contain the actual name of a model to which a comment belongs. The migration:

create_table :comments do |t|
  t.text :body
  t.integer :commentable_id
  t.string :commentable_type

  t.timestamps
end
add_index :comments, :commentable_id
can be re-written as:

create_table :comments do |t|
  t.text :body
  t.references :commentable, polymorphic: true, index: true

  t.timestamps
end
add_index :comments, :commentable_id
We’ve already seen the references method before, but this time it also comes with a :polymorphic option.

Apply the migration:

$ rake db:migrate
The Comment model is going to have the belongs_to association, but with a small twist:

models/comment.rb

[...]
belongs_to :commentable, polymorphic: true
[...]
As long as we called our fields :commentable_id and :commentable_type, the whole relation has to be called commentable.

Now the User and Game models:

models/user.rb

[...]
has_many :comments, as: :commentable
[...]
models/game.rb

[...]
has_many :comments, as: :commentable
[...]
:as is a special option explaining that this is a polymorphic association. Now, boot your console and try running:

$ u = User.create
$ u.comments.create({body: 'test'})
Inside the comments table, commentable_type will be set to User and commentable_idto the user’s id. Your polymorphic association works great and now you can easily make other models commentable!

Conclusion
In this article, we’ve discussed various types of associations available in Rails. We’ve seen how to set them up and further customize. Official documentation contains a nice reference for each association, so be sure to check it out if you haven’t already done so.

Hopefully, this article was a useful brush-up of your knowledge. Stay tuned and see you soon!

Ilya Bodrov-Krukowski
Ilya Bodrov-Krukowski
Ilya Bodrov is personal IT teacher, a senior engineer working at Campaigner LLC, author and teaching assistant at Sitepoint and lecturer at Moscow Aviations Institute. His primary programming languages are Ruby (with Rails) and JavaScript. He enjoys coding, teaching people and learning new things. Ilya also has some Cisco and Microsoft certificates and was working as a tutor in an educational center for a couple of years. In his free time he tweets, writes posts for his website, participates in OpenSource projects, goes in for sports and plays music.

