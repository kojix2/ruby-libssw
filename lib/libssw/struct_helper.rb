# frozen_string_literal: true

module LibSSW
  module StructHelper
    def to_h
      self.class.keys.map { |k| [k, __send__(k)] }.to_h
    end

    def to_ptr
      @ptr
    end
  end
end
