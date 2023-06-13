FROM ruby:2.6

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir /redmine
WORKDIR /redmine

COPY Gemfile /redmine/Gemfile
COPY Gemfile.lock /redmine/Gemfile.lock
RUN bundle install
COPY . /redmine

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
