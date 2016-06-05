require 'savon'

module FreshupClient
  module Soap
    
    class GroupInterfaceClient

      def initialize
        @client = Savon::Client.new("http://#{$GAMESERVER_HOST}:#{$GAMESERVER_PORT}/webserverInterfaceGroup?wsdl")
        #puts @client.wsdl.soap_actions
      end
            
      def player_view_group_members_request(session, groupid)
        resp = @client.request :player_view_group_members_request do
    
          soap.body = {
            :session => session,
            :group_id => groupid,
          }
        end
    
        puts resp.to_hash
    
        value = resp.body[:player_view_group_members_request_response][:return]
        
        return [] if "USERNOTINGROUP" == value[:error]
        
        raise value[:error] if ERRORS.member? value[:error]

        array value[:players]
        
      end

      def view_group_member_by_group(session, groupid)
        resp = @client.request :view_group_member_by_group do 
    
          soap.body = {
            :session => session,
            :groupid => groupid,
          }
        end
    
        puts resp.to_hash
    
        value = resp.body[:view_group_member_by_group_response][:return]
        
        return nil if "USERNOTINGROUP" == value[:error]
        
        raise value[:error] if ERRORS.member? value[:error]

        array value[:players]
        
      end
     
      def get_exchange_counter(session, groupid)
        resp = @client.request :get_exchange_counter do
    
          soap.body = {
            :session => session,
            :group_id => groupid
          }
        end
    
        puts resp.to_hash
    
        value = resp.body[:get_exchange_counter_response][:return]
    
        raise value if ERRORS.member? value

        value
        
      end

      def group_has_active_tasks(session, group_id)
        resp = @client.request :group_has_active_tasks do
          soap.body = {
            :session => session,
            :deck_id => group_id
          }
        end
        value = resp.body[:group_has_active_tasks_response][:return]

        puts value
        value
      end

      ###########
      #
      # Neu!

      def get_open_group_decks(session)
        resp = @client.request :get_open_group_decks do
          soap.body = {
            :session => session
          }
        end
        puts resp.to_hash
        
        values = resp.body[:get_open_group_decks_response][:return]
        puts "--> get_open_group_decks"
        puts values
        raise values[:error] if values[:error]
        values

      end

      def join_group(session, player_id, deck_id)
        resp = @client.request :join_group do
          soap.body = {
            :session => session,
            :playerid => player_id,
            :deckid => deck_id
          }
        end
        puts resp.to_hash

        values = resp.body[:join_group_response][:return]
        
        puts values
        raise values[:error] if values[:error]
        values
      end

      def create_group(session, deck_id)
        resp = @client.request :create_group_request do
          soap.body = {
            :session => session,
            :deckid => deck_id
          }
        end
        puts resp.to_hash

        values = resp.body[:create_group_request_response][:return]

        puts values
        raise values[:error] if values[:error]
        values
      end

      def group_leave(session, groupid)
        resp = @client.request :leave_group do
          soap.body = {
            :session => session,
            :groupid => groupid
          }
        end
        puts resp.to_hash

        values = resp.body[:leave_group_response][:return]

        puts values
        raise values[:error] if values[:error]
        values
      end

      def create_group_alone(session, deckid)
        resp = @client.request :create_group_alone do
          soap.body = {
            :session => session,
            :deckid => deckid
          }
        end
        puts resp.to_hash

        values = resp.body[:create_group_alone_response][:return]

        puts values
        raise values[:error] if values[:error]
        values
      end

      def get_group_summary(session, player_id)
        resp = @client.request :get_group_summary do
          soap.body = {
            :session => session,
            :playerid => player_id
          }
        end
        puts resp.to_hash

        values = resp.body[:get_group_summary_response][:return]
        puts "--> get_group_summary"
        puts values
        raise values[:error] if values[:error]
        values

      end

      def group_delete_request(session, deck_id)
        resp = @client.request :delete_group_request do
          soap.body = {
            :session => session,
            :deckid => deck_id
          }
        end
        puts resp.to_hash

        values = resp.body[:delete_group_request_response][:return]

        puts values
        raise values[:error] if values[:error]
        values
      end

      def get_open_group_slots(session)
        resp = @client.request :get_open_group_slots do
          soap.body = {
            :session => session
          }
        end
        puts resp.to_hash

        values = resp.body[:get_open_group_slots_response][:return]

        puts values
        raise values[:error] if values[:error]
        values
      end
      
    end

  end
end