SKIP_CALLBACKS = true

priorities = %w{high medium low}
change_types = %w{planned unplanned}
impacts = ['downtime', 'system outage', 'none']
systems = %w{Amazon-S3 Amazon-EC2 Amazon-IAM CloudFlare-DNS CloudFlare-PAGERULE CloudFlare-SETTING CloudFlare-ACL DNS-CREATE DNS-UPDATE DNS-DESTROY Rightscale-CREDENTIALS Rightscale-INPUTS Rightscale-FIREWALL Rightscale-USER}
statuses = %w(new pending approved completed rejected aborted)
users = ['tom jones', 'bill smith', 'tony doorman', 'mike snow', 'robert wimby', 'sean turner', 'victor hernandez']
countries = %w{us ca uki fr br}
products = ['Sage One', 'Sage Drive', 'Sage View']

puts 'seeding countries'
countries.each do |country|
  Country.new(:name => country.upcase).save
end

puts 'seeding products'
products.each do |product|
  Country.all.each do |country|
    Product.new(:name => product, :country => country).save
  end
end


puts 'seeding priorities'
priorities.each do |priority|
  Priority.create(:name => priority)
end

puts 'seeding change types'
change_types.each do |change_type|
  ChangeType.create(:name => change_type)
end

puts 'seeding impacts'
impacts.each do |impact|
  Impact.create(:name => impact)
end

puts 'seeding systems'
systems.each do |system|
  category,name = system.split('-')
  System.create(:category => category,:name => name)
end

puts 'seeding statuses'
statuses.each do |status|
  Status.create(:name => status)
end

if ENV['RAILS_ENV'] == 'development'
  puts 'seeding users'
  users.each do |user|
    user_email = "#{user.split(' ').join('_')}@mailinator.com"
    User.create(:name => user.titleize, :email => user_email)
  end
  # user = User.create(:name => 'Stevenson Jean-Pierre', :email => 'stevenson.jean-pierre@sage.com' )
  # Service.create(:user => user, :provider => 'github', :uid => ENV['GH_UID'])

  puts 'seeding changes'
  20.times do
    user = User.all.sample(1).first
    Change.create(
        :title => "Change created by #{user.name}",
        :priority_id => Priority.all.sample(1).first.id,
        :system_id => System.all.sample(1).first.id,
        :status_id => Status.for_seed.sample(1).first.id,
        :change_type_id => ChangeType.all.sample(1).first.id,
        :impact_id => Impact.all.sample(1).first.id,
        :product => Product.all.sample(1).first,
        :summary => 'this is a summary',
        :change_date => Date.strptime(Time.now.strftime('%m/%d/%Y'), '%m/%d/%Y'),
        :rollback => 'this is the rollback',
        :creator => user
    )
  end

  puts 'seeding comments'
  Change.all.each do |change|
    User.all.each do |user|
      @comment = Comment.build_from(change, user.id,"Comment by #{user.name}", "#{user.name} was here and made a comment on change with title #{change.title}" )
      @comment.save!
    end
  end

  puts 'seeding approvers'
  Change.all.each do |change|
    User.all.each do |approver|
      change.approvers.build(:user_id => approver.id)
    end
    change.save!
  end
end
