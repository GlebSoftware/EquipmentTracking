FROM ruby:2.6.0
WORKDIR /redmine
COPY Gemfile /redmine/Gemfile
COPY Gemfile.lock /redmine/Gemfile.lock
RUN gem update --system 3.2.3
RUN gem install bundler:2.4.10
RUN bundle install
RUN gem install rails
RUN bundle show
COPY . /redmine
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
