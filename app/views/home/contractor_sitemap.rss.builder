# app/views/posts/index.rss.builder

xml.instruct!
xml.urlset "xmlns"=>"http://www.sitemaps.org/schemas/sitemap/0.9","xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance","xsi:schemaLocation"=>"http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" do
	for contractor in @contractors
	  xml.url do
	    xml.loc "#{Kluje.host}/en/public/profile/#{contractor.company_name_slug}"
	    xml.changefreq "daily"
	    xml.priority '1.0'
	  end
	end
end
