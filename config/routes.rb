if Rails::VERSION::MAJOR < 3

    ActionController::Routing::Routes.draw do |map|
        map.connect('mentions/:id', :controller => 'mentions', :action => 'index')
    end

else

    match('mentions/:id', :to => 'mentions#index')

end
