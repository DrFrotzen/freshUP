require 'savon'

module FreshupClient
  module Soap

    class TaskClient
  
      def initialize()
        @client = Savon::Client.new("http://localhost:1337/adminInterface?wsdl")
        
      end


      def create_new_admin(admin,newAdmin)
    
        resp = @client.request :create_new_admin do
          soap.body = {
	    :admin_username => admin[:username],
	    :admin_password => admin[:password],
	    :new_admin_username => newAdmin[:username],
	    :new_admin_password => newAdmin[:password],
	    :new_admin_rank => newAdmin[:rank],
	    :new_admin_course => newAdmin[:course]
	  }
        end
    
        puts resp.body.to_hash
    
        resp.body[:create_new_admin_response][:return]
   
      end
      
      def delete_admin(admin,delAdmin)
    
        resp = @client.request :delete_admin do
          soap.body = {
	    :adminUsername => admin[:username],
	    :adminPassword => admin[:password],
	    :adminUsernameToDelete => delAdmin
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

	puts resp.to_hash 
	
	resp.body[:view_filtered_interaction_simple_response][:return]

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

      def get_all_check_type
    
        resp = @client.request :get_all_check_type 
	
        puts resp.body.to_hash
    
        resp.body[:get_all_check_type_response][:return]
    
      end

      def get_all_admins(username,password)
    
        resp = @client.request :get_all_admins do
          soap.body = {
	    :adminUsername => username,
	    :adminPassword => password	    
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:get_all_admins_response][:return]
    
      end

      def create_interaction(option,frage)
    
        resp = @client.request :create_interaction do
          soap.body = {
	    :username => option[:username],
	    :password => option[:password],
	    :interaction => frage
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:create_interaction_response][:return]
    
      end

      def update_interaction(option,frage)
    
        resp = @client.request :update_interaction do
          soap.body = {
	    :username => option[:username],
	    :password => option[:password],
	    :interaction => frage
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:update_interaction_response][:return]
    
      end

      def get_associated_solution(interactionId)
    
        resp = @client.request :get_associated_solution do
          soap.body = {
	    :interactionId => interactionId
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:get_associated_solution_response][:return]
    
      end
      
      def get_all_pattern_masks
    
        resp = @client.request :get_all_pattern_masks
	
        puts resp.body.to_hash
    
        resp.body[:get_all_pattern_masks_response][:return]
    
      end

      def get_check_type(checkTypeId)
    
        resp = @client.request :get_check_type do
	  soap.body = {
	    :checkTypeId => checkTypeId
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:get_check_type_response][:return]
    
      end

      def get_deck(deckId)
    
        resp = @client.request :get_deck do
	  soap.body = {
	    :deckId => deckId
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:get_deck_response][:return]
    
      end
      
      def get_course(courseId)
    
        resp = @client.request :get_course do
	  soap.body = {
	    :id => courseId
	  }
	end
	
        puts resp.body.to_hash
    
        resp.body[:get_course_response][:return]
    
      end

      
    end
  end
end
 
