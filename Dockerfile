FROM ruby:2.6.3

LABEL maintainer=OceanEx

ARG git_revision_id
# Allow customization of user ID and group ID (it's useful when you use Docker bind mounts)
ARG UID=2000
ARG GID=2000

ENV APP_HOME=/home/app \
  GIT_REVISION_ID=${git_revision_id} \
  TZ=UTC
# throw errors if Gemfile has been modified since Gemfile.lock
RUN groupadd -r --gid ${GID} app \
  && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
  --gid ${GID} --uid ${UID} app \
  # Install system dependencies.
  && apt-get update \
  && gem install bundler:2.1.4

RUN bundle config --global frozen 1
WORKDIR $APP_HOME

COPY Gemfile  Gemfile.lock $APP_HOME/
RUN bundle install

COPY --chown=app:app . $APP_HOME

# Switch to application user.
USER app

RUN chmod +x  ./bin/slanger

EXPOSE 4567 8080

CMD bundle exec ./bin/slanger --app_key $APP_KEY --secret $APP_SECRET -r $REDIS_URL
