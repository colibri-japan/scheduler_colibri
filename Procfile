web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -e production -c 3 -v
release: rails db:migrate