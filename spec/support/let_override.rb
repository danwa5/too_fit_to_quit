# See https://github.com/rspec/rspec-core/issues/294
module RSpec::LetOverride
  def let_override(name, &block)
    let_override!(name) do |value|
      instance_exec(value, &block)
      value
    end
  end

  def let_override!(name, &block)
    define_method(name) do
      __memoized.fetch_or_store(name) { instance_exec(super(), &block) }
    end
  end
end

RSpec::Core::ExampleGroup.module_eval do
  extend RSpec::LetOverride
end
