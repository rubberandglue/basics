capistrano recipie
------------------

    cap app:tail
    cap app:setup # Installs gcc, git, curl, libs for nginx
    cap db:mysql:setup # creates the db with the shared database.yml file
    cap db:mysql:drop_setup # not implemented (in case of problems)

show_attributes
---------------

USAGE: 

    <%= show_attributes(@model) do |m| %>
      <%= m.dl(:name) %>
      <%= m.dl(:description) %>
    <% end %>
