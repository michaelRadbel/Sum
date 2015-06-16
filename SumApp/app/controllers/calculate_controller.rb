class CalculateController < ApplicationController
	def addition
		#for addition, add the three results
		if params[:commit] == "Add"
			@result = params[:firstNumber].to_i  + 
					params[:secondNumber].to_i + 
					params[:thirdNumber].to_i
		end
			
	end
end
