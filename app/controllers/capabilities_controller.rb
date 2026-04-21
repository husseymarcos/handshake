class CapabilitiesController < ApplicationController
  def create
    Current.professional.add_capability(capability_params[:name])
    redirect_back fallback_location: career_path, notice: "Capability added."
  rescue ActiveRecord::RecordInvalid
    redirect_back fallback_location: career_path, alert: "Capability name can't be blank."
  end

  def destroy
    capability = Current.professional.capabilities.find(params[:id])
    Current.professional.remove_capability(capability)
    redirect_back fallback_location: career_path, notice: "Capability removed."
  end

  private

    def capability_params
      params.require(:capability).permit(:name)
    end
end
