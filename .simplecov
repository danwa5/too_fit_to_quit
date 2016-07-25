SimpleCov.start 'rails' do
  add_group 'Services', 'app/services'
  add_filter 'spec'
  add_filter 'app/controllers/users/confirmations_controller.rb'
  add_filter 'app/controllers/users/passwords_controller.rb'
  add_filter 'app/controllers/users/registrations_controller.rb'
  add_filter 'app/controllers/users/sessions_controller.rb'
  add_filter 'app/controllers/users/unlocks_controller.rb'
end
