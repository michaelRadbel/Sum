SumApp::Application.routes.draw do
  #to get the claculate homepage
  get "calculate" => "calculate#addition"
  post "calculate/addition"
end
