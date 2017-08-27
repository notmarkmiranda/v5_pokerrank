class ParticipantsController < ApplicationController
  before_action :require_user
  before_action :load_and_verify_ownership, only: [:show, :edit, :update]

  def show
  end

  def new
    @participant = current_user.participants.new
  end

  def create
    @participant = current_user.participants.new(participant_params)
    if @participant.save
      redirect_to @participant
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @participant.update(participant_params)
      redirect_to @participant
    else
      render :edit
    end
  end

  private

  def load_and_verify_ownership
    @participant = current_user.participants.where(id: params[:id]).first
  end

  def participant_params
    params.require(:participant).permit(:first_name, :last_name)
  end
end
