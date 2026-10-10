# frozen_string_literal: true

module Shared
  class ComboboxComponent < ViewComponent::Base
    Option = Data.define(:value, :group, :badge) do
      def initialize(value:, group: nil, badge: nil) = super
    end

    attr_reader :id, :name, :value, :placeholder, :label, :error, :group, :input_class, :autofocus

    def initialize(id:, name:, options:, value: nil, placeholder: nil, label: nil, error: nil, group: nil, input_class: nil, autofocus: false) # rubocop:disable Metrics/ParameterLists
      @id = id
      @name = name
      @options = options
      @value = value
      @placeholder = placeholder
      @label = label
      @error = error
      @group = group
      @input_class = input_class
      @autofocus = autofocus
    end

    def options
      @options.map { it.is_a?(Option) ? it : Option.new(**it) }
    end
  end
end
