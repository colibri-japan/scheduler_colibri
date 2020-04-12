web: bundle exec puma -C config/puma.rb
webpack: bin/webpack-dev-server
worker: bundle exec sidekiq -e production -c 3
release: rails db:migrate