require 'dry/matcher/either_matcher'

module Services
  # Public: The interface for method objects useful for performing a particular
  # bit of business logic or a business process, each of which are single purpose.
  #
  # Examples
  #
  #   class FoobarService
  #     include Services::BaseService
  #
  #     def initialize(bool)
  #       @bool = bool
  #     end
  #
  #     def call
  #       @bool ? Dry::Monads::Right('a success') : Dry::Monads::Left('a failure')
  #     end
  #   end
  #
  #   FoobarService.call(true)
  #   # => Right("a success")
  #
  #   FoobarService.call(true) do |m|
  #     m.succss do |v|
  #       "Matched success: #{v}"
  #     end
  #
  #     m.failure do |v|
  #       "Matched failure: #{v}"
  #     end
  #   end
  #   # => "Matched success: a success"
  #
  module BaseService
    def self.included(target)
      target.send(:include, Dry::Matcher.for(:call, with: Dry::Matcher::EitherMatcher))
      target.send(:include, Dry::Monads::Either::Mixin)
      target.send(:include, Dry::Monads::Try::Mixin)
      target.send(:include, InstanceMethods)
      target.extend ClassMethods
    end

    module InstanceMethods
      # Public: The called method by the service. The including class must
      # implement this method.
      #
      # Return must be a `Dry::Monad::Either` or `Dry::Monad::Try`
      def call
        raise NotImplementedError
      end
    end

    module ClassMethods
      # Public: Initialize the service (method object) and make the call.
      #
      # args  - The argument options that are implemented by the including class
      # block - An optional block that can be used to return on result matches
      #         of either 'success' or 'failure'.
      #
      # Return must be the result or match.
      def call(*args, &block)
        if block_given?
          new(*args).call(&block)
        else
          new(*args).call
        end
      end
    end
  end
end
