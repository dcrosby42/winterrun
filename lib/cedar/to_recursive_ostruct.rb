# (from 'max pleaner' StackOverflow answer https://stackoverflow.com/a/42520668)
require "ostruct"

def to_recursive_ostruct(hash)
  OpenStruct.new(hash.each_with_object({}) do |(key, val), memo|
    memo[key] = val.is_a?(Hash) ? to_recursive_ostruct(val) : val
  end)
end

# (dcrosby 2020-12-26 - convenience:)

def open_struct(h = nil)
  to_recursive_ostruct(h || {})
end

OpenStruct.define_singleton_method(:deep) do |h| to_recursive_ostruct(h) end
