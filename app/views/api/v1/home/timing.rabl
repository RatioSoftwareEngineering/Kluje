collection false

@timings.each do |key|
  node(key[0]){ key[1] }
end