class Array
  def subtract_once(b)
    h = b.inject({}) {|memo, v|
      memo[v] ||= 0; memo[v] += 1; memo
    }
    reject { |e| h.include?(e) && (h[e] -= 1) >= 0 }
  end
end