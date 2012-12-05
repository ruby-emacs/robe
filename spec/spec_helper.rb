require 'pry'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module ScannerHelper
  def new_module(imethod, method, private_imethod, private_method)
    Module.new do
      eval <<-EOS
        def #{imethod}; end
        private
        def #{private_imethod}; end
        class << self
          def #{method}; end
          private
          def #{private_method}; end
        end
      EOS
    end
  end

  def named_module(name, *args)
    new_module(*args).tap do |m|
      m.instance_eval "def name; \"#{name}\" end"
    end
  end
end

class MockSpace
  def initialize(*modules)
    @modules = modules
  end

  def fits?(type, m)
    true
  end

  def each_object(type)
    @modules.select { |m| fits?(type, m) }.each { |m| yield m if block_given? }
  end
end

class KindSpace < MockSpace
  def fits?(type, m)
    m.kind_of? type
  end
end