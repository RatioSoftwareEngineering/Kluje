xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title   "Kluje Blog"
  xml.link    "rel" => "self", "href" => blog_url
  xml.id      blog_url
  xml.updated @posts.first.updated_at.strftime "%Y-%m-%dT%H:%M:%SZ" if @posts.any?
  xml.author  { xml.name "Padrino Team" }

  @posts.each do |post|
    xml.entry do
      xml.title   post.title
      xml.link    "rel" => "alternate", "href" => post_blog_url(post: post.slug_url)
      xml.id      post_blog_url(post: post.slug_url)
      xml.updated post.updated_at.strftime "%Y-%m-%dT%H:%M:%SZ"
      xml.author  { xml.name post.account.full_name }
      xml.summary post.body
    end
  end
end
