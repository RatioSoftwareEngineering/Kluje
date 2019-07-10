collection false

@contact_times.each do |key|
  node(key[0]){ key[1] }
end