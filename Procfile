web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -e production
release: rails db:migrate