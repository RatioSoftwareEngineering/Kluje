require 'mandrill'

MANDRILL_CLIENT = Mandrill::API.new Settings['mandrill']['api_key']

module MandrillRenderer
  def self.render template_name, vars
    begin
      template_content = [{"name"=>"editable", "content"=>""}]
      merge_vars = vars.map{|k,v| {name: k, content: v}}
      MANDRILL_CLIENT.templates.render(template_name, template_content, merge_vars)
    rescue Mandrill::Error => e
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      raise
    end
  end
end
