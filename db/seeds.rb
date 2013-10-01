# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
priorities = %w{high medium low other}
change_types = %w{emergency planned}
impacts = ['downtime','system outage','none']
system = %w{DNS Rightscale Cloudflare Amazon Sage Zuora S3}
statuses = %w(new pending completed aborted rejected)
users = %w('tom jones', 'bill smith', 'tony doorman')

priorities.each do |priority|
  Priority.create(:name => priority)
end

change_types.each do |change_type|
  ChangeType.create(:name => change_type)
end

impacts.each do |impact|
  Impact.create(:name => impact)
end

system.each do |service|
  System.create(:name => service)
end

statuses.each do |status|
  Status.create(:name => status)
end

users.each do |user|
  user_email = "#{user.split('').join('_')}@test.com"
  User.create(:name => user, :email => user_email)
end
