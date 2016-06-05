require 'savon'

module FreshupClient
  module Soap

    class AdminInterfaceClient
  
      def initialize()
        @client = Savon::Client.new("http://#{$GAMESERVER_HOST}:#{$GAMESERVER_PORT}/webserverInterfaceAdmin?wsdl")
        
        #@options = options
        
        #puts "methods of AdminInterfaceClient"
        #puts @client.wsdl.soap_actions
      end
      
      def authenticate(options)
        resp = @client.request :authenticate do
          soap.body = options
        end
        
        value = resp.body[:authenticate_response][:return]
        if value.is_a? String
          raise value
        else
          return value
        end
      end
  
      def get_all_study_courses
        resp = @client.request :get_all_study_courses

        values = resp.body[:get_all_study_courses_response][:return]
        put values
        raise values if ERRORS.member? values

        values
    
      end
  
  
      def start_game(options)
    
        resp = @client.request :start_game do
          soap.body = options
        end
    
        puts resp.body.to_hash
    
        resp.body[:start_game_response][:return]
    
      end
  
      def end_game(options)
    
        resp = @client.request :end_game do
          soap.body = options
        end
    
        puts resp.body.to_hash
    
        resp.body[:end_game_response][:return]
    
      end

      def restart_game(options)
        resp = @client.request :restart_game do
          soap.body = options
        end

        puts resp.body.to_hash

        resp.body[:restart_game_response][:return]

      end

      def game_cleardb(options)

        resp = @client.request :clear_db do
          soap.body = options
        end

        puts resp.body.to_hash

        value =resp.body[:clear_db_response][:return]
        raise value[:error] if ERRORS.member? value[:error]
        value

      end

      def change_to_login_phase(options)

        resp = @client.request :change_to_login_phase do
          soap.body = options
        end

        puts resp.body.to_hash

        resp.body[:change_to_login_phase_response][:return]

      end

      def get_game_config(options)
        resp = @client.request :get_game_config do
          soap.body = options
        end
        puts resp.to_hash
        value = resp.body[:get_game_config_response][:return]
        raise value[:error] if ERRORS.member? value[:error]
        value
        
      end

      def set_game_start_time(options, start_year, start_month, start_day, start_hour, start_minute)
        resp = @client.request :set_game_start_end_time do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :game_start_year => start_year,
            :game_start_month => start_month,
            :game_start_day => start_day,
            :game_start_hour => start_hour,
            :game_start_minute => start_minute
          }
        end
        puts "Startzeit_setzen"
        puts resp.body.to_hash

        value = resp.body[:set_game_start_end_time_response][:return]
        puts value
        #raise value[:error] if ERRORS.member? value[:error]
        value
      end

      def set_game_end_time(options,  end_year, end_month, end_day, end_hour, end_minute)
        resp = @client.request :set_game_end_time do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :game_end_year => end_year,
            :game_end_month => end_month,
            :game_end_day => end_day,
            :game_end_hour => end_hour,
            :game_end_minute => end_minute
          }
        end

        puts resp.body.to_hash

        value = resp.body[:set_game_end_time_response][:return]
        raise value[:error] if ERRORS.member? value[:error]
        value
      end

  
      def get_game_phase(options = {})
        resp = @client.request :get_game_phase
        puts resp.body.to_hash
    
        resp.body[:get_game_phase_response][:return]
      end

      def get_max_group_size (options)

        resp = @client.request :get_max_group_size do
          soap.body = options
        end

        puts resp.body.to_hash

        return resp.body[:get_max_group_size_response][:return]
      end


      def set_max_interactions(options, max_interaction)
        resp = @client.request :set_max_interactions do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :max_interactions => max_interaction
          }
        end

        puts resp.body.to_hash

        resp.body[:set_max_interactions_response][:return]
      end


      def get_max_interactions (options)

        resp = @client.request :get_max_interactions do
          soap.body = options
        end

        puts resp.body.to_hash

        return resp.body[:get_max_interactions_response][:return]
      end


      def set_max_exchange_counter(options, max_exchange_counter)
        resp = @client.request :set_max_exchange_counter do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :new_max_exchange_counter => max_exchange_counter
          }
        end

        puts resp.body.to_hash

        resp.body[:set_max_exchange_counter_response][:return]
      end
  
      def get_max_exchange_counter (options)

        resp = @client.request :get_max_exchange_counter do
          soap.body = options
        end

        puts resp.body.to_hash

        return resp.body[:get_max_exchange_counter_response][:return]
      end


      def set_max_group_size(options, max_group_size)
        resp = @client.request :set_max_group_size do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :max_group_size => max_group_size
          }
        end

        puts resp.body.to_hash

        resp.body[:set_max_group_size_response][:return]
      end

      def view_all_groups(options)
        resp = @client.request :view_all_groups do
          soap.body = {
            :username => options[:username],
            :password => options[:password]
          }
        end

        puts resp.to_hash
	  
        return resp.body[:view_all_groups_response][:return]
      end


      def users_without_group(options)
        resp = @client.request :users_without_group do
          soap.body = options
        end

        puts resp.body.to_hash
        puts resp.to_hash

        return resp.body[:users_without_group_response][:return][:item]

      end

      def get_user_infos(options, user_id)
        resp = @client.request :get_user_infos do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :player => user_id
          }
        end

        puts resp.body.to_hash
        puts resp.to_hash

        return resp.body[:get_user_infos_response][:return]

      end
  
      def group_create(options, studycourse)
        resp = @client.request :group_create do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :studycourse_id => studycourse
          }
        end 

        puts resp.body.to_hash
        values = resp.body[:group_create_response][:return]
        puts values
        values
      end

      def group_add_player(options, group_id, player_id)
        resp = @client.request :group_add_player do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :player => player_id,
            :group_id => group_id
          }
        end

        puts resp.body.to_hash

        resp.body[:group_add_player_response][:return]
      end

      def group_remove_player(options, group_id, player_id)
        resp = @client.request :group_remove_player do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :player => player_id,
            :group_id => group_id
          }
        end

        puts resp.body.to_hash

        resp.body[:group_remove_player_response][:return]
      end

      @deprecadet
      def get_external_news
        resp = @client.request :read_external_news

        puts resp.body.to_hash

        resp.body[:read_external_news_response][:return]
      end

      def read_internal_news(options)

        resp = @client.request :read_internal_news do
          soap.body = options
        end

        puts resp.to_hash

        values = resp.body[:read_internal_news_response][:return]

        return array(values[:news]) unless values[:error]

        return [] if values[:error] == 'NONEWS'

        raise values[:error]

      end
      
      def get_all_bonus_interaction options
        resp = @client.request :get_all_bonus_interaction do
          soap.body = options
        end 

        puts resp.body.to_hash
    
        resp.body[:get_all_bonus_interaction_response][:return]
        
      end

      def get_all_rallye_decks options
        resp = @client.request :get_all_rallye_decks do
          soap.body = options
        end

        puts resp.body.to_hash

        resp.body[:get_all_rallye_decks_response][:return]

      end
      
      def is_open_test
        resp = @client.request :is_open_test

        puts resp.body.to_hash

        resp.body[:is_open_test_response][:return]

      end

      def give_bonus_interaction_to_all(username, password, interaction_id,
          start_hour, start_minute, start_day, start_month, start_year,
          solvable_hour, solvable_minute, solvable_day, solvable_month, solvable_year,
          end_hour, end_minute, end_day, end_month, end_year)
        resp = @client.request :give_bonus_interaction_to_all do
          soap.body = {
            :username => username,
            :password => password,
            :interaction_i_d => interaction_id,
            :start_day => start_day,
            :start_month => start_month,
            :start_year => start_year,
            :start_hour => start_hour,
            :start_minute => start_minute,
            :solvable_since_day => solvable_day,
            :solvable_since_month => solvable_month,
            :solvable_since_year => solvable_year,
            :solvable_since_hour => solvable_hour,
            :solvable_since_minute => solvable_minute,
            :end_day => end_day,
            :end_month =>  end_month,
            :end_year => end_year,
            :end_hour => end_hour,
            :end_minute => end_minute

          }
        end

        puts resp.body.to_hash

        resp.body[:give_bonus_interaction_to_all_response][:return]

      end

      def add_one_external_news(options, text)
        resp = @client.request :add_external_news do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :text => text
          }
        end

        puts resp.body.to_hash

        resp.body[:add_external_news_response][:return]
      end

      def add_one_internal_news(options, text)
        resp = @client.request :add_internal_news do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :text => text
          }
        end

        puts resp.body.to_hash

        resp.body[:add_internal_news_response][:return]
      end

      def delete_all_external_news(options)
        resp = @client.request :delete_all_external_news do
          soap.body = {
            :username => options[:username],
            :password => options[:password]
          }
        end

        puts resp.body.to_hash

        resp.body[:delete_all_external_news_response][:return]
      end

      def delete_all_internal_news(options)
        resp = @client.request :delete_all_internal_news do
          soap.body = {
            :username => options[:username],
            :password => options[:password]
          }
        end

        puts resp.body.to_hash

        resp.body[:delete_all_internal_news_response][:return]
      end

      def delete_one_external_news(options, delete_date)
        resp = @client.request :delete_one_external_news do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :delete_date => delete_date
          }
        end

        puts resp.body.to_hash

        resp.body[:delete_one_external_news_response][:return]
      end

      def delete_one_internal_news(options, delete_date)
        resp = @client.request :delete_one_internal_news do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :delete_date => delete_date
          }
        end

        puts resp.body.to_hash

        resp.body[:delete_one_internal_news_response][:return]
      end

      def get_ranking_all(options)
        resp = @client.request :get_ranking_all do
          soap.body = options
        end

        puts resp.to_hash

        value = resp.body[:get_ranking_all_response][:return]

        return [] if 'EMPTY' == value[:error]

        raise value[:error] if ERRORS.member? value[:error]

        array value[:ranked_groups]

      end

      def group_view_members_specific(options, group_id)
        resp = @client.request :group_view_members_specific do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id => group_id
          }
        end

        puts resp.to_hash

        return resp.body[:group_view_members_specific_response][:return]
      end


      def mail_to (options, playeruser_ids, subject, message, with_bcc)
        resp = @client.request :mail_to do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :playeruser_i_ds => {:item => playeruser_ids},
            :subject => subject,
            :message => message,
            :with_bcc => with_bcc
          }
        end

        puts resp.body.to_hash

        resp.body[:mail_to_response][:return]
      end

      def get_all_player(options)
        resp = @client.request :get_all_player do
          soap.body = {
            :username => options[:username],
            :password => options[:password]
          }
        end

        puts resp.to_hash

        return resp.body[:get_all_player_response][:return]
      end

      def give_interactions_to_group(options, group_id)
        resp = @client.request :give_interactions_to_group do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id=> group_id
          }
        end

        puts resp.body.to_hash

        resp.body[:give_interactions_to_group_response][:return]
      end

      def give_interactions_to_player(options, player_id)
        resp = @client.request :give_interactions_to_player do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :user_id=> player_id
          }
        end

        puts resp.body.to_hash

        resp.body[:give_interactions_to_player_response][:return]
      end

      def give_interactions_to_all(options)
        resp = @client.request :give_interactions_to_all do
          soap.body = {
            :username => options[:username],
            :password => options[:password]
          }
        end

        puts resp.body.to_hash

        resp.body[:give_interactions_to_all_response][:return]
      end

      def give_card_to_group(options, group_id, interaction_id)
        resp = @client.request :give_card_to_group do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id=> group_id,
            :task_id => interaction_id
          }
        end
        puts resp.body.to_hash
        resp.body[:give_card_to_group_response][:return]
      end

      def give_card_to_player(options, player_id, interaction_id)
        resp = @client.request :give_card_to_player do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :player_id=> player_id,
            :task_id => interaction_id
          }
        end
        puts resp.body.to_hash
        resp.body[:give_card_to_player_response][:return]
      end

      def group_take_card(options, group_id, interaction_id)
        resp = @client.request :group_take_card do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id=> group_id,
            :taskId => interaction_id
          }
        end

        puts resp.body.to_hash

        resp.body[:group_take_card_response][:return]
      end

      def group_disable(options, group_id)
        resp = @client.request :group_disable do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id=> group_id
          }
        end

        puts resp.body.to_hash

        resp.body[:group_disable_response][:return]
      end

      def group_enable(options, group_id)
        resp = @client.request :group_enable do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id=> group_id
          }
        end

        puts resp.body.to_hash

        resp.body[:group_enable_response][:return]
      end

      def get_group_rank(options, groupid)
        resp = @client.request :get_group_rank do
          soap.body = {
            :admin_username => options[:username],
            :admin_password => options[:password],
            :group_id => groupid
          }
        end

        puts resp.body.to_hash
        values = resp.body[:get_group_rank_response][:return]
        puts values
        values
      end

      def decrement_wrong_attempts(options, groupid, number)
        resp = @client.request :decrement_wrong_attempts do
          soap.body = {
            :admin_username => options[:username],
            :admin_password => options[:password],
            :group_id => groupid,
            :number =>  number
          }
        end

        puts resp.body.to_hash
        values = resp.body[:decrement_wrong_attempts_response][:return]
        puts values
        values
      end


      def recalculate_points(options)
        resp = @client.request :recalculate_points do
          soap.body = {
            :admin_username => options[:username],
            :admin_password => options[:password]
          }
        end

        puts resp.body.to_hash
        values = resp.body[:recalculate_points_response][:return]
        puts values
        values
      end

      def give_interactions_to_all(options)
        resp = @client.request :give_interactions_to_all do
          soap.body = {
            :username => options[:username],
            :password => options[:password]
          }
        end

        puts resp.body.to_hash

        resp.body[:give_interactions_to_all_response][:return]
      end

      def give_interactions_to_player(options, playerid)
        resp = @client.request :give_interactions_to_player do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :player_id => playerid
          }
        end

        puts resp.body.to_hash

        resp.body[:give_interactions_to_player_response][:return]
      end

      def give_interactions_to_group(options, groupid)
        resp = @client.request :give_interactions_to_group do
          soap.body = {
            :username => options[:username],
            :password => options[:password],
            :group_id => groupid
          }
        end

        puts resp.body.to_hash

        resp.body[:give_interactions_to_group_response][:return]
      end


    end
    
  end
end
