BitdiddleSec::Application.routes.draw do
  resources :keys

  root :to => "keys#help"
end
