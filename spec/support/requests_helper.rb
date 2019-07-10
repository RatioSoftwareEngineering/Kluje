module RequestsHelper
  def json
    o = JSON(response.body)
    if o.is_a?(Hash)
      o.with_indifferent_access
    else
      o
    end
  end
end
