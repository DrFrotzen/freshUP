require 'savon'

module FreshupClient
  module Soap

    class CommunicationInterfaceClient

      def initialize
        @client = Savon::Client.new("http://#{$GAMESERVER_HOST}:#{$GAMESERVER_PORT}/webserverInterfaceCommunication?wsdl")
        #puts @client.wsdl.soap_actions
      end

      def get_in_messages_for_user session
        resp = @client.request :get_in_messages_for_user do
          soap.body = {
            :session => session
          }
        end

        puts resp.to_hash

        values = resp.body[:get_in_messages_for_user_response][:return]
        raise values[:error] if values[:error]
        array values[:messages]
      end

      def get_out_messages_for_user session
        resp = @client.request :get_out_messages_for_user do
          soap.body = {
            :session => session
          }
        end

        puts resp.to_hash

        values = resp.body[:get_out_messages_for_user_response][:return]
        raise values[:error] if values[:error]
        array values[:messages]
      end

      def get_new_messages_for_user session
        resp = @client.request :get_new_messages_for_user do
          soap.body = {
            :session => session
          }
        end

        puts resp.to_hash

        values = resp.body[:get_new_messages_for_user_response][:return]
        raise values[:error] if values[:error]
        array values[:messages]
      end

      def send_message session, to_userid, content
        resp = @client.request :send_message do
          soap.body = {
            :session => session,
            :user_id => to_userid,
            :content => content,
          }
        end

        puts resp.to_hash

        value = resp.body[:send_message_response][:return]
        raise value if ERRORS.member? value
        value
      end

      def mark_message_as_read session, message_id
        resp = @client.request :mark_message_as_read do
          soap.body = {
            :session => session,
            :message_id => message_id,
          }
        end

        puts resp.to_hash

        value = resp.body[:mark_message_as_read_response][:return]
        raise value if ERRORS.member? value
        value
      end

      def delete_message session, message_id
        resp = @client.request :delete_message do
          soap.body = {
            :session => session,
            :message_id => message_id,
          }
        end

        puts resp.to_hash

        value = resp.body[:delete_message_response][:return]
        raise value if ERRORS.member? value
        value
      end

      def get_new_messages_count_for_user(sessionid)
        resp = @client.request :get_new_messages_count_for_user do
          soap.body = {
            :session => sessionid
          }
        end
        puts resp.to_hash
        values = resp.body[:get_new_messages_count_for_user_response][:return]
        raise values[:error] if values[:error]
        values
      end
      
      def get_external_news

        resp = @client.request :get_external_news

        puts resp.to_hash

        values = resp.body[:get_external_news_response][:return]

        return array(values[:news]) unless values[:error]

        return [] if values[:error] == 'NONEWS'

        raise values[:error]

      end


      def get_internal_news(session)

        resp = @client.request :get_internal_news do
          soap.body = {
            :session => session
          }
        end

        puts resp.to_hash

        values = resp.body[:get_internal_news_response][:return]

        return array(values[:news]) unless values[:error]

        raise values[:error]

      end 
  
    end
  end
end
