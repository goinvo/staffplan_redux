class RegistrationsController < Devise::RegistrationsController
  def new
    @company = Company.new
    super
  end

  def create
    @company = Company.new(company_params)
    super do |user|
      if user.persisted?
        if @company.save
          @company.users << user
        else
          resource_saved = false
        end
      else
        #TODO: WTF?
      end
    end
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end

end
