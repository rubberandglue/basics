capistrano recipie
------------------

    cap app:tail
    cap app:setup # Installs gcc, git, curl, libs for nginx


show_attributes
---------------

USAGE: 

    <%= show_attributes(@model) do |m| %>
      <%= m.dl(:name) %>
      <%= m.dl(:description) %>
    <% end %>
