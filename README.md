Ruby on Rails 5.1
=================

Notes for [Aarhus.rb](https://www.meetup.com/aarhusrb) presentation 2017-11-06.

### What is new in [Ruby on Rails](http://rubyonrails.org) 5.1?

Actually not so much have changed since Rails 5.0, but still some interesting stuff;

- No more rake, use rails instead;

        bin/rails db:migrate

        bin/rails -T
        # => list of available targets

- [Puma](http://puma.io) now default web server

- Systems tests with [Capybara](http://teamcapybara.github.io/capybara/) (+[Selenium](http://www.seleniumhq.org)) vs. Integration Vs. Controller tests fully configured and ready to go

- [Yarn](https://yarnpkg.com/en/) now manages JavaScript dependencies (to eventually replace all the old unmaintained Javascript wrapper gems) with [Webpack](https://webpack.js.org) using [Webpacker](https://github.com/rails/webpacker) gem -- optionally add [Angular](https://angularjs.org), [Elm](http://elm-lang.org), [React](https://reactjs.org) or [Vue.js](https://vuejs.org).

- [jQuery](https://jquery.org) no longer included after rewriting jquery-ujs to rails-ujs removing any jQuery references.

- Encrypted secrets

        bin/rails secrets:setup
    
    __Note:__ remember the generated key and keep keyfile secret!

        bin/rails secrets:edit

- Lots of smaller changes; ActionMailer default parameters; declarative exception handling in ActiveJob; ERB handler changed from `Erubis` to `Erubi`; direct and resolved routes; `form_with` replaces `form_for` and `form_tag` and new `tag` helper; BIGINT for primary keys (for select DBs); migrations supports virtual columns (for select DBs); 

- And some deprecations, too.  Check changelogs for details ...

Demo project
------------

Prepare demo project folder

    mkdir demo
    cd demo
    git init
    echo "2.4.2" > .ruby-version
    chruby 2.4.2
    git add .ruby-version
    git commit -m "Initial commit"

    echo "source 'https://rubygems.org'" > Gemfile
    echo "gem 'rails', '~> 5.1.4'" >> Gemfile
    ln -s ~/src/bundle-shared-2.4.2 .bundle
    bundle install
    bundle exec rails --version
    # => Rails 5.1.4

    git add Gemfile Gemfile.lock
    git commit -m "Initial Gemfile"

### New Rails app

Create new Rails app with Webpack

    bundle exec rails new . --webpack

    bin/rails db:create db:migrate # `bin/rails db:setup` requires `schema.rb`.

    git add .
    git commit -m "Rails new . --webpack"

New files

    app/
        javascript/
            # app.vue
            packs/
                application.js
                # hello_vue.js
    bin/
        webpack
        webpack-dev-server
        yarn
    config/
        webpack/
            <ENV>.js
        cable.yml
        puma.rb
        secrets.yml{.enc,.key}
        spring.rb
        webpacker.yml
    node_modules
    test/
        ...
    .babelrc
    .postcssrc.yml
      plugins:
        postcss-smart-import: {}
        postcss-cssnext:
          browserslist:
            - last 2 versions
            - IE >= 9
            - iOS >= 9
            - > 1%
    package.json
    yarn.lock

Let's scaffold something to work with...

    bin/rails generate scaffold post title:string:index content:text due_date:date extra:string
    bin/rails generate scaffold comment post:belongs_to content:text
    bin/rake db:migrate
    git add .
    git commit -m "Scaffold something"

    bin/rails s
    open http://localhost:3000/posts

### Yarn / Webpacker

Yarn is now default JavaScript asset manager.

Basic --webpack delegation to new webpacker gem;

    bin/rails new --webpack ...
    bin/rails new --webpack=react|vue ...
    bin/rails webpacker:install
    bin/rails webpacker:install:react|vue
    bin/rails webpacker:compile
    ...

To include webpacker application pack, add:

    # app/views/layouts/application.html.erb
    <%= javascript_pack_tag 'application' %>

and reload browser to check it logs a message to console.

... TODO (requries erb loader)

    # app/javascript/packs/application.js.erb
    <% helpers = ActionController::Base.helpers %>
    var railsImagePath = "<%= helpers.image_path('rails.png') %>"

### Styling with Bootstrap, jQuery-UI

Add Bootstrap + Datepicker (jQuery-UI);

    # yarn init (shold not be required if installed by rails new)
    yarn add bootstrap

    # app/assets/javascripts/application.js
    //= require bootstrap/dist/js/bootstrap

    # app/assets/stylesheets/aplication.css
    *= require bootstrap/dist/css/bootstrap

Refresh browser to see Bootstrap CSS is now ready for our service :-)

_But_ JavaScript not so much; browser console says: `Error: Bootstrap's JavaScript
requires jQuery` ... well that's easy to fix;

    yarn add jquery

    # app/assets/javascripts/application.js
    //= require jquery // jquery/dist/jquery

Verify it actually works; adding an alert with close button to view

    <div class="alert alert-warning alert-dismissible fade in" role="alert"> <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button> <strong>Alert!</strong> Check Bootstrap JavaScript works by closing this box. </div>

Commit changes so far...

    git add .
    git commit -m "yarn add bootstrap + jquery"

We would also like jQuery-UI tools like datepicker, so

    yarn add jquery-ui

    # app/assets/javascripts/application.js
    //= require jquery-ui/ui/widgets/datepicker

    # app/assets/stylesheets/aplication.css
    *= require jquery-ui/themes/base/all

and try giving a form field `class="date-picker"`

    # app/views/posts/_form.html.erb
    <div class="field">
      <%= form.label :due_date %>
      <%= form.text_field :due_date, id: :post_due_date, class: 'date-picker' %>
    </div>

see it works in browser console;

    $("input.date-picker").datepicker
    < ...
    $("input.date-picker").datepicker()

and click field to open date picker :-)

Commit changes so far...

    git add .
    git commit -m "yarn add jquery-ui"

Maybe try moving JavaScript requires to `app/javascripts/packs/application.js` so it is available from JavaScript packs;

    import jQuery from 'jquery'
    window.jQuery = jQuery
    window.$ = jQuery

    require('bootstrap/dist/js/bootstrap')
    require('jquery-ui/ui/widgets/datepicker')

again, try in browser console:

    $("input.date-picker").datepicker()

and click field to check date picker enabled.

Commit changes so far...

    git add .
    git commit -m "Move JavaScript require from assets to javascript/packs"

#### JavaScript testing

Add Jest (alt. Sinon+Mocha+Chai);

    yarn add --dev jest

Create javascript specs dir;

    mkdir test/javascript

Add to `package.json`;

    "scripts": {
      "test": "jest"
    },
    "jest": {
      "roots": [
        "test/javascript"
      ],
      "moduleDirectories": [
        "node_modules",
        "app/javascript"
      ]
    },

Write a simple test;

    # test/javascript/sum.spec.js
    test('1 + 1 equals 2', () => {
      expect(1 + 1).toBe(2);
    });

Run test;

    yarn test

Slightly more advanced example add Babel/es2015 to provide `import` et.al.:

    yarn add --dev babel-jest babel-preset-es2015

    # .babelrc
    "presets": [
      "es2015",
      ...

    # app/javascript/Dinosaur.js
    export default class Dinosaur {
      get isExtinct() {
        return true;
      }
    }

    # test/javascript/Dinosaur.spec.js
    import Dinosaur from 'Dinosaur';
    test('Dinosaurs are extinct', () => {
      expect((new Dinosaur).isExtinct).toBeTruthy();
    });

and run tests;

    yarn test

Commit changes so far...

    git add .
    git commit -m "Add JavaScript testing usinng Jest"

#### Adding Vue.js (or React or Angular or ...)

Add Vue.js to application;

    bin/rails webpacker:install:vue

and include the generated Vue.js pack in layout;

    # app/views/layouts/application.html.erb
    <%= stylesheet_pack_tag 'hello_vue' %>
    <%= javascript_pack_tag 'hello_vue' %>

now reload browser to check Vue.js running.

... TODO ...

    bin/webpack-dev-server # auto-reload browser on JavaScript changes
    bin/webpack # compile JavaScript pack(s)
    bin/rails webpacker:compile # compile JS pack(s) for production
    ...

#### TODO: JavaScript Initializers

We still need to initialize datepicker on page load (and using turbolinks);

    mkdir app/assets/javascripts/initializers

    # app/assets/javascripts/initializer.js
    (function() {
        this.App || (this.App = {});

        App.onLoadFns = [];

        App.onPageLoad = function(callback) {
            App.onLoadFns.push(callback);
        }

        App.load = function() {
            App.onLoadFns.forEach(function(callback, _index) {
                callback.call(App);
            });
        };
    }).call(this);

    $(function() {
        // Called everytime turbolinks loads a new page
        $(document).on("turbolinks:load", function() {
            App.load();
        });

        // Called on initial full page load
        //
        // defer to allow all features to register their
        // page load callbacks before App.load runs
        setTimeout(App.load, 1);
    });

    # app/assets/javascripts/initializers/date-picker.js
    App.onPageLoad(function() {
        $("input.date-picker").datepicker({
            firstDay: 1,
            dateFormat: "yy-mm-dd"
        });
    });

### Tests

#### Integration tests

#### System tests with Capybara

Auto generated system tests...

    # test/system/post_test.rb
    require 'application_system_test_case'

    class PostTest < ApplicationSystemTestCase
      test "visiting the 'posts' page" do
        visit posts_url
        assert_selector 'h1', text: 'Posts'
      end
    end

    $ bin/rails test:system

- Everything set up and ready to use

- Automatic screenshot when test fails - manual screenshot; just call `take_screenshot` at any point within a test

- No need for database_cleaner

- Re-run single test :-)

- Easy to (re-)configure Capybara; replace Selenium+Chromedriver with poltergeist/phantomjs

        gem 'poltergeist'
        bundle install

        # test/test/application_system_test_case.rb
        driven_by :poltergeist

Running tests
    
    bin/rails test
    bin/rails test:system

### TODO: routes...

#### links to embedded content (post/comments)

    # config.routes.rb
    direct(:embedded_content) do |content|
      url_for [content.post, anchor: "content-#{content.id}"]
    end

    <%= link_to "Comment #2", embedded_content_path(@comment)

#### singular resources

    <form action="/profile" accept-charset="UTF-8" method="post">
      ...
    </form>

    # config/routes.rb
    resource :profile
    resolve('Profile') { [:profile] }

    # app/views/profiles/new.html.erb
    <%= form_for @profile do |f| %>
      ...
    <% end %>



Prerequisites
-------------

### Ruby

Install [Ruby](https://www.ruby-lang.org/en/) (maybe via [ruby-install](https://github.com/postmodern/ruby-install) + [chruby](https://github.com/postmodern/chruby) using [Homebrew](https://brew.sh))

    brew install ruby-install chruby
    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh

    ruby-install --latest
    # => ...
    ruby-install ruby 2.4.2

    # need to reload chruby to select new ruby
    . /usr/local/share/chruby/chruby.sh
    chruby 2.4.2
    ruby --version
    # => ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin16]

Ensure we have a recent [Bundler](http://bundler.io) installed on current Ruby

    gem install bundler
    bundle --version
    # => Bundler version 1.15.4

### Node

Install [Node.JS](https://nodejs.org/en/) (maybe via [NVM: Node Version Manager](http://nvm.sh) using Homebrew)

    brew install nvm
    nvm --version
    0.33.4

    nvm ls
    nvm install v8.1.0
    nvm use 8.1
    # => Now using node v8.1.0 (npm v5.3.0)

### Yarn

Install [Yarn](https://yarnpkg.com/en/), (e.g. using Homebrew):

    brew install yarn # or brew upgrade yarn
    yarn --version
    1.1.0 # was: 0.27.5

### Selenium WebDriver

Install WebDriver(s) for Selenium;
    
    brew install chromedriver

or, if using [Poltergeist](https://github.com/teampoltergeist/poltergeist)/[PhantomJS](http://phantomjs.org);

    brew install phantomjs

    # Gemfile
    gem 'poltergeist'
    bundle install

    # test/test/application_system_test_case.rb
    driven_by :poltergeist

### Misc

Create shared bundler dir

    mkdir -p ~/src/bundle-shared-2.4.2

### References and inspiration

- [Ruby on Rails 5.1](http://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/)

- [RailsCarma: What's new in Rails 5.1](http://www.railscarma.com/blog/technical-articles/whats-new-rails-5-1/) and [Nithin Bekal: What's new in Rails 5.1](http://nithinbekal.com/posts/rails-5.1-features/)

- [gh:rails/webpacker](https://github.com/rails/webpacker)

- [Vue.js](https://vuejs.org) - [Up and Running with Vue.js](https://blog.codeship.com/up-and-running-with-vue-js/)

- [The Wonderful World of Webpack](http://jackhiston.com/2017/9/4/the-wonderful-world-of-webpack/)

- [A Guide to Testing Rails Applications](http://guides.rubyonrails.org/testing.html)

- [Full-Stack Testing with Rails System Tests](https://chriskottom.com/blog/2017/04/full-stack-testing-with-rails-system-tests/)

- [Testing JavaScript app](https://medium.com/@kylefox/how-to-setup-javascript-testing-in-rails-5-1-with-webpacker-and-jest-ef7130a4c08e)

- ...
