module Sandbox
  Engine.routes.draw do
    root :to => 'sandbox/play#index'
  end
end
