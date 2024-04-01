module Shared
  class ManageAvatarComponent < ViewComponent::Base
    def initialize(attachable:, form:)
      @attachable = attachable
      @form = form
    end

    def f
      @form
    end
  end
end