require 'savon'

module FreshupClient
  module Soap

    class GameInterfaceClient

      def initialize
        @client = Savon::Client.new("http://#{$GAMESERVER_HOST}:#{$GAMESERVER_PORT}/webserverInterfaceGame?wsdl")
        #puts @client.wsdl.soap_actions
      end


      def change_one_active_interaction(session, interaction)
        resp = @client.request :change_one_active_interaction do

          soap.body = {
            :session => session,
            :interaction => interaction,
          }
        end

        puts resp.to_hash

        value = resp.body[:change_one_active_interaction_response][:return]

        raise value if ERRORS.member? value

        value

      end

      def get_all_solved_interactions(session, group_id)
        resp = @client.request :get_all_solved_interactions do
          soap.body = {
            :session => session,
            :group_id => group_id
          }
        end
        puts resp.to_hash

        values = resp.body[:get_all_solved_interactions_response][:return]
        puts "--> get_all_solved_interactions"
        puts values
        raise values[:error] if values[:error]
        values

      end

      def get_meta_data_for_one_solved_interaction(session, interaction)
        resp = @client.request :get_meta_data_for_one_solved_interaction do
          soap.body = {
            :session => session,
            :interaction => interaction,
          }
        end

        puts resp.to_hash
        values = resp.body[:get_meta_data_for_one_solved_interaction_response][:return]
        raise values[:error] if values[:error]
        values
      end 

      def get_ranking(session)
        resp = @client.request :get_ranking do

          soap.body = {
            :session => session,
          }
        end

        puts resp.to_hash

        value = resp.body[:get_ranking_response][:return]

        return [] if 'EMPTY' == value[:error]

        raise value[:error] if ERRORS.member? value[:error]
        
        array value[:ranked_player]
      end

      def validate_solution(session, interaction, part1, part2)
        resp = @client.request :validate_solution do

          soap.body = {
            :session => session,
            :interaction => interaction,
            :solutionPart1 => part1,
            :solutionPart2 => part2,
          }
        end

        puts resp.to_hash

        value = resp.body[:validate_solution_response][:return]

        #raise value if ERRORS.member? value

        value

      end

      def get_interaction(session, interaction)
        resp = @client.request :get_interaction do

          soap.body = {
            :session => session,
            :interaction => interaction,
          }
        end

        puts resp.to_hash

        values = resp.body[:get_interaction_response][:return]

        raise values[:error] if values[:error]

        values

      end

      def get_all_active_interactions(session)
        resp = @client.request :get_all_active_interactions do
          soap.body = {
            :session => session,
          }
        end

        values = resp.body[:get_all_active_interactions_response][:return]
        puts values
        raise values[:error] if values[:error]
        values

      end

      def get_my_rank(session)
        resp = @client.request :get_my_rank do
          soap.body = {
            :session => session
          }
        end

        puts resp.to_hash
        value = resp.body[:get_my_rank_response][:return]
        raise value if ERRORS.member? value
        value
      end

      def get_player_statistic(session, player_id)
        resp = @client.request :get_player_statistick_request do
          soap.body = {
            :session => session,
            :player_id => player_id
          }
        end

        puts resp.to_hash
        value = resp.body[:get_player_statistic_response][:return]
        raise value if ERRORS.member? value
        value
      end

      def get_special_solved_interaction(session, interaction)
        resp = @client.request :get_special_solved_interaction do
          soap.body = {
            :session => session,
            :interaction => interaction,
          }
        end

        puts resp.to_hash
        values = resp.body[:get_special_solved_interaction_response][:return]
        raise values[:error] if values[:error]

        values
      end

      def get_interaction_matrix(session)
        resp = @client.request :get_interaction_matrix do
          soap.body = {
            :session => session,
          }
        end

        #puts resp.to_hash
        values = resp.body[:get_interaction_matrix_response][:return]
        raise values[:error] if values[:error]
        values
      end

      def get_group_deck_summary(session)
        resp = @client.request :get_group_deck_summary do
        soap.body = {
          :session => session
        }
        end
        values = resp.body[:get_group_deck_summary_response][:return]

        puts values
        raise values[:error] if values[:error]
        values

      end

  
    end
  end
end
