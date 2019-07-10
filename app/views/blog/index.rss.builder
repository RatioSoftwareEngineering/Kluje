xml.instruct!
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title "Kluje Blog"
    xml.description "Find local contractors in #{current_country.name} approved by others. Post a job, get a quote and pick the most reliable, highest rated contractor!"
    xml.link blog_url

    for post in @posts
      xml.item do
        xml.title post.title
        xml.description post.body
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post_blog_url(post: post.slug_url)
        xml.guid post_blog_url(post: post.slug_url)
      end
    end
  end
end
