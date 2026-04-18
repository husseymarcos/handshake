class SkillsController < ApplicationController
  def create
    Current.user.add_skill(skill_params[:name])
    redirect_back fallback_location: user_path(Current.user), notice: "Skill added."
  rescue ActiveRecord::RecordInvalid
    redirect_back fallback_location: user_path(Current.user), alert: "Skill name can't be blank."
  end

  def destroy
    skill = Current.user.skills.find(params[:id])
    Current.user.remove_skill(skill)
    redirect_back fallback_location: user_path(Current.user), notice: "Skill removed."
  end

  private

    def skill_params
      params.require(:skill).permit(:name)
    end
end
