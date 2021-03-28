module RunLevel
  Placeholder = Component.new(:placeholder, { name: "UNSET", data: nil })

  Placeholder_search = EntityFilter.new(Placeholder)

  def placeholder_entities(estore)
    estore.search(Placeholder_search)
  end

  def with_placeholder(estore, name)
    e = placeholder_entities(estore).find do |e| e.placeholder.name == name end
    yield e.placeholder if e && block_given?
  end
end
