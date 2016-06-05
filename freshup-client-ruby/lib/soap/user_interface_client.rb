require 'savon'

module FreshupClient
  module Soap

    class UserInterfaceClient

      def initialize
        @client = Savon::Client.new("http://#{$GAMESERVER_HOST}:#{$GAMESERVER_PORT}/webserverInterfaceUser?wsdl")
        #puts @client.wsdl.soap_actions
      end
  
      def test_say_hello
        resp = @client.request :test_say_hello
    
        resp.body[:return]
      end
  
      def test_echo(string)
        resp = @client.request :test_echo do
          soap.body = {
            :string => string, 
          }
        end
    
        resp.body[:test_echo_response][:return]    
      end

      def login_register(username, password)

        resp = @client.request :login_register do
          soap.body = {
            :username => username,
            :password => password,  
          }
        end
  
        return resp.body[:login_register_response][:return]

      end

  
      def login(username, password)
        resp = @client.request :login do
          soap.body = {
            :username => username,
            :password => password,  
          }
        end
    
        keys = [:userid, :session]
        values = resp.body[:login_response][:return][:item]

        unless values.is_a?(Array) && values.length == keys.length
          values = [values, nil]
        end

        return Hash[*keys.zip(values).flatten]

      end


      def register(
        firstname, lastname, username, password, sex, studycours_ids, reason,
        devicesensors=['true', 'true', 'true', 'true', 'true', 'true']
        )
    
        resp = @client.request :register do
          soap.body = {
            :firstname => firstname,
            :lastname => lastname,  
            :username => username,
            :password => password,
            :sex => sex,  
            :devicesensors => {:item => devicesensors},  
            :studycours_ids => {:item => studycours_ids},
            :reason => reason,
          }
        end

        value = resp.body[:register_response][:return]
        unless ERRORS.member? value
          return value
        else
          raise value
        end

      end
  
      def session_to_user_id(session)
        resp = @client.request :session_to_user_id do
          soap.body = {
            :session => session,
          }
        end
        
        puts resp.to_hash
        
        value = resp.body[:session_to_user_id_response][:return]
        
        raise value[:error] if ERRORS.member? value[:error]
        
        value[:int]
        
      end
  
  
      def user_infos(userid, session)
        puts "user_infos_123"
        puts userid
        puts "user_infos_1234"
        resp = @client.request :user_infos do
          soap.body = {
            :session => session,
            :userid => userid,
          }
        end
    
        puts resp.to_hash
    
    
        #keys = [:firstname, :lastname, :userid, :studycourse, :sex, :photo, :videoplay, :videorec, :position, :audiorec, :audioplay, :mail]

        values = resp.body[:user_infos_response][:return]
        raise values if ERRORS.member? values

        values
        #if values.is_a?(Array) && values.length == keys.length
        #  return Hash[*keys.zip(values).flatten]
        #else
        #  return raise values.to_s
        #end
      end

      def store_meta_data_request(session, devicesensor =['true', 'true', 'true', 'true', 'true', 'true', 'true'])
        puts session
        puts devicesensor
        resp = @client.request :store_meta_data_request do
          soap.body = {
            :session => session,
            :metadata => {:item => devicesensor}
          }
        end
        puts resp.to_hash
        resp.body[:store_meta_data_request_response][:return]

      end 
      
      def search_user session, keyword
        resp = @client.request :search_user do
          soap.body = {
            :session => session,
            :keyword => keyword,
          }
        end
    
        puts resp.to_hash
        
        value = resp.body[:search_user_response][:return]
        raise value[:error] if ERRORS.member? value[:error]
        value[:int_list]
      end

      def get_exchange_counter(session)
        resp = @client.request :get_exchange_counter do
          soap.body = {
            :session => session,
          }
        end
        puts resp.to_hash
        value = resp.body[:get_exchange_counter_response][:return]
        raise value if ERRORS.member? value
        value
      end
      

      def get_all_user_badges(sessionid, targetid)
        resp = @client.request :get_all_user_badges do

          soap.body = {
            :session => sessionid,
            :target_id => targetid
          }
        end

        puts resp.to_hash

        value = resp.body[:get_all_user_badges_response][:return]

        raise value[:error] if ERRORS.member? value[:error]

        array value[:badges]

      end

      def get_recent_user_badges(sessionid, targetid)
        resp = @client.request :get_recent_user_badges do

          soap.body = {
            :session => sessionid,
            :target_id => targetid
          }
        end

        puts resp.to_hash

        value = resp.body[:get_recent_user_badges_response][:return]

        raise value[:error] if ERRORS.member? value[:error]

        array value[:badges]

      end

      def timeline_post(sessionid, count)
        @client.request :timeline_post do
          soap.body = {
            :session => sessionid,
            :count => count
          }
        end
      end

      def recruit_user(sessionid, mail_address, name, message)
        resp = @client.request :recruit_user do
          soap.body = {
            :session => sessionid,
            :mail_address => mail_address,
            :name => name,
            :message => message
          }
        end
        puts resp.to_hash
        value = resp.body[:recruit_user_response][:return]
        value
      end

      def get_users_with_same_study_courses(session)
        resp = @client.request :get_users_with_same_study_courses do

          soap.body = {
            :session => session
          }
        end

        puts resp.to_hash

        value = resp.body[:get_users_with_same_study_courses_response][:return]

        puts "--->"
        puts value
        raise value[:error] if ERRORS.member? value[:error]

        array value[:player]

      end

    end
  end
end
