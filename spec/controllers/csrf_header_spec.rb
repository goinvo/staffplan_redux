require 'rails_helper'

class ExampleController < ApplicationController
  def index
    head :ok
  end
end

RSpec.describe ExampleController, type: :controller do
  controller {}

  describe 'any controller action in the app' do
    it 'sets an X-CSRF-Token header value' do
      expect(controller).to receive(:form_authenticity_token).and_return(token = 'a csrf token')

      get :index

      expect(response.headers['X-CSRF-Token']).to eq(token)
    end
  end
end