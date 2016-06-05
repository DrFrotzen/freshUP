require 'savon'

module FreshupClient
  module Soap

    class TaskClient
  
      def initialize()
        @client = Savon::Client.new("http://localhost:1337/adminInterface?wsdl")
        
      end


      def create_new_admin(admin,newAdmin,adminAttributes)
    
        resp = @client.request :create_new_admin do
          soap.body = {
	    :admin_username => admin[:username],
	    :admin_password => admin[:password],
	    :new_admin_username => newAdmin[:username],
	    :new_admin_password => newAdmin[:password],
	    :new_admin_rank => adminAttributes[:rank],
	    :new_admin_course => adminAttributes[:course]
	  }
        end
    
        puts resp.body.to_hash
    
        resp.body[:create_new_admin_response][:return]
   
      end
      
      def delete_admin(admin,delAdmin)
    
        resp = @client.request :delete_admin do
          soap.body = {
	    :admin_username => admin[:username],
	    :admin_password => admin[:password],
	    :admin_username_to_delete => delAdmin[:username]
	  }
        end
    
        puts resp.body.to_hash
    
        resp.body[:delete_admin_response][:return]
   
      end      
      
      def get_interaction(task_id)
    
        resp = @client.request :get_interaction do
          soap.body = {
	    :interaction_id => task_id
	  }
        end
    
        puts resp.body.to_hash
    
        resp.body[:get_interaction_response][:return]
    
      end


      def view_filtered_interaction_simple(task_id)
    
        resp = @client.request :view_filtered_interaction_simple do
          soap.body = {
	    :filter => task_id
	  }
        end
    
        puts resp.body.to_hash

	resp.body[:view_filtered_interaction_simple_response][:return]
   

	puts resp.to_hash 
	
	values = resp.body[:view_filtered_interaction_response][:return]

	raise values[:error] 
	if values[:error]
	  values
	end
      end
      
      
      def view_filtered_interaction(task_id,l2,l3)
    
        resp = @client.request :view_filtered_interaction do
          soap.body = {
	    :filter => task_id,
	    :group_deck => l2,
	    :bonus_interaction => l3
	  }
        end
    
        puts resp.body.to_hash

	resp.body[:view_filtered_interaction_response][:return]
   
      end
      
      
      def get_all_courses
    
        resp = @client.request :get_all_courses 
	
        puts resp.body.to_hash
    
        resp.body[:get_all_courses_response][:return]
    
      end

      def get_all_decks
    
        resp = @client.request :get_all_decks 
	
        puts resp.body.to_hash
    
        resp.body[:get_all_decks_response][:return]
    
      end

    end
  end
end
 
