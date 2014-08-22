class AssignmentsController < ApplicationController
  def index
    @assignments = current_user.current_company.assignments
  end

  def show
    @assignment = current_user.current_company.assignments.find(params[:id])
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)

    if @assignment.save
      flash[:notice] = "The assignment was created successfully"
      redirect_to assignment_path(@assignment)
    else
      flash.now[:notice] = "Couldn't create the assignment"
      render :new
    end
  end

  def edit
    @assignment = current_user.current_company.assignments.find(params[:id])
  end

  def update
    @assignment = current_user.current_company.assignments.find(params[:id])

    if @assignment.update(assignment_params)
      flash[:notice] = "The assignment was updated successfully"
      redirect_to assignment_path(@assignment)
    else
      flash.now[:notice] = "Couldn't update your assignment"
      render :edit
    end
  end

  def destroy
    @assignment = current_user.current_company.assignments.find(params[:id])

    @assignment.destroy
    flash[:notice] = "The assignment was deleted"
    redirect_to assignments_path
  end

  private

  def assignment_params
    params.require(:assignment).permit(:user_id, :project_id, :proposed)
  end
end
