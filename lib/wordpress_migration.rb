# require 'nokogiri'
# require 'open-uri'
# PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)
# doc = Nokogiri::HTML(open("#{PADRINO_ROOT}/db/data/wordpress.xml"))
# doc.search('item').each do |item|
# 	title = item.search("title")
# 	body = item.search("encoded")
# 	cat = []
# 	item.search("category").each do |category|
# 		cat << category.attr('nicename')
# 	end
# 	meta_keyword = cat.join(' ')
# 	meta_description = title
# 	slug_url = item.search('post_name').to_s.split('-').join(' ')
# 	categories = []
# 	cat.each do |c|
# 		categories << Blog::Category.create(name: c.to_s)
# 	end
# 	@post = Blog::Post.create(title: title,body: body,meta_keyword: meta_keyword,meta_description: meta_description,slug_url: slug_url,author: "Andrew",author_google_plus_url: "https://plus.google.com/u/0/107710118317110227833")
# 	categories.each do |cat|
# 		PostCategory.create(category_id: cat.id,post_id: @post.id)
# 	end
# end
