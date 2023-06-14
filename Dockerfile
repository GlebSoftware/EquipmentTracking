FROM ruby:2.7.0
WORKDIR /redmine
COPY Gemfile /redmine/Gemfile
COPY Gemfile.lock /redmine/Gemfile.lock
RUN gem update --system
RUN gem install bundler
RUN bundle install
RUN gem install rails
RUN bundle show
COPY . /redmine
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
