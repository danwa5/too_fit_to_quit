module Presenters
  class Base
    include Rails.application.routes.url_helpers

    def self.presents(name)                        # 'presents :order' in class
      define_method(name) {subject}                # creates a method #order in
    end                                            # the instance

    attr_reader :subject

    def initialize(subject)
      @subject = subject
    end

    # def self.from_array(ary)
    #   ary.collect { |item| new(item) }
    # end
  end
end
