require 'csv'

ActiveRecord::Base.connection.execute('TRUNCATE TABLE skills')
ActiveRecord::Base.connection.execute('ALTER TABLE skills AUTO_INCREMENT = 1')
CSV.foreach("#{Rails.root}/db/data/skills.csv", headers: :first_row) do |row|
  row.to_hash.with_indifferent_access
  row = row.to_hash.symbolize_keys
  # set the id from the CSV file and not auto increment
  skill = Skill.new(name: row[:name]) do |s|
    s.id = row[:id]
  end
  skill.save
end

ActiveRecord::Base.connection.execute('TRUNCATE TABLE job_categories')
ActiveRecord::Base.connection.execute('ALTER TABLE job_categories AUTO_INCREMENT = 1')
CSV.foreach("#{Rails.root}/db/data/job_categories.csv", headers: :first_row) do |row|
  row.to_hash.with_indifferent_access
  JobCategory.create!(row.to_hash.symbolize_keys)
end

ActiveRecord::Base.connection.execute('TRUNCATE TABLE categories')
ActiveRecord::Base.connection.execute('ALTER TABLE categories AUTO_INCREMENT = 1')
CSV.foreach("#{Rails.root}/db/data/categories.csv", headers: :first_row) do |row|
  row.to_hash.with_indifferent_access
  Category.create!(row.to_hash.symbolize_keys)
end

ActiveRecord::Base.connection.execute('TRUNCATE TABLE budgets')
ActiveRecord::Base.connection.execute('ALTER TABLE budgets AUTO_INCREMENT = 1')
CSV.foreach("#{Rails.root}/db/data/budgets.csv", headers: :first_row) do |row|
  row.to_hash.with_indifferent_access
  Budget.create!(row.to_hash.symbolize_keys)
end

file = "#{Rails.root}/db/data/wordpress_redirect.csv"
CSV.open(file, 'w') do |writer|
  doc1 = Nokogiri::HTML(open("#{Rails.root}/db/data/wordpress.xml"))
  doc2 = Nokogiri::HTML(open("#{Rails.root}/db/data/posts.xml"))
  (0..doc1.search('item').count - 1).each do |i|
    item = doc1.search('item')[i]
    old_url = item.search('link').first.next.text
    old_url.slice! "\n\t\t"
    old_url.slice! 'http://www.kluje.com/blog'
    new_url = doc2.search('loc')[i].text
    writer << [old_url, new_url]
  end
end

doc = Nokogiri::HTML(open("#{Rails.root}/db/data/wordpress.xml"))
doc.search('item').each do |item|
  title = item.search('title').text.to_s
  url = item.search('link').first.next.text
  url.slice! "\n\t\t"
  url.slice! 'http://www.kluje.com'
  encoded = []
  item.search('encoded').each do |en|
    encoded << en.to_s
  end
  body = encoded.join(' ').to_s
  cat = []
  item.search('category').each do |category|
    cat << category.attr('nicename')
  end
  meta_keyword = cat.join(',').to_s
  meta_description = title.to_s
  # slug_url = item.search('post_name').to_s.split('-').join(' ').to_s

  @post = Post.create(
    title: title, body: body, meta_keyword: meta_keyword,
    meta_description: meta_description,
    slug_url: url, author: 'Andrew',
    author_google_plus_url: 'https://plus.google.com/u/0/107710118317110227833'
  )

  Category.all.each do |c|
    PostCategory.create(category_id: c.id, post_id: @post.id)
  end
end

countries_cities = {
  'Indonesia' => %w(Bandung Yogyakarta Denpasar)
}

countries_cities.each do |country_name, cities|
  country = Country.find_by_name country_name
  cities.each do |city_name|
    City.find_or_create_by(country_id: country.id, name: city_name, available: true)
  end
end

Post.all.find_each do |post|
  post.update_columns(post_type: :blog) if post.post_type.blank?
end

if Rails.env != 'test' && !Account.find_by_role('admin')
  shell ||= Thor::Base.shell.new
  shell.say ''

  first_name = shell.ask 'What is your first name?'
  last_name = shell.ask 'What is your last name?'
  email = shell.ask 'Which email do you want use for logging into admin?'
  password = shell.ask 'Tell me the password to use:'

  account = Account.create(
    email: email, first_name: first_name, last_name: last_name,
    password: password, password_confirmation: password, mobile_number: '88888888', role: 'admin'
  )
  account.save!

  if account.valid?
    shell.say '===================================================================='
    shell.say 'Admin account has been successfully created, now you can login with:'
    shell.say '===================================================================='
    shell.say "   First Name: #{first_name}"
    shell.say "   Last Name:  #{last_name}"
    shell.say "   Email:      #{email}"
    shell.say "   Password:   #{password}"
    shell.say '===================================================================='
  else
    shell.say 'Sorry but some thing went wrong!'
    shell.say ''
    account.errors.full_messages.each { |m| shell.say "   - #{m}" }
  end

  shell.say ''
end
