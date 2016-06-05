#!/bin/env ruby
# encoding: utf-8
require 'lib/soap'

module FreshupClient
  
      
  class AdminUI < Sinatra::Base
    enable :sessions
    
    register Sinatra::Contrib
    
    register Sinatra::Partial
    enable :partial_underscores

    use Rack::Flash
    
    set :root, File.dirname(__FILE__)
    set :logging, true
    
    helpers do
      include Haml::Helpers
      alias_method :h, :html_escape

      def url_for original_url
        original_url
      end

      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="FreshUP Admin Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end
      
      def credentials
        {
          :username => @auth.credentials[0],
          :password => @auth.credentials[1],
        }
      end
 #wandelt string in boolean um     
      def to_boolean(str)
	str == "true"
      end
 #entfernt key aus einem hash
      def get_type_name(str)
        if str == "Fact"
	  return "Faktenwissen"
	elsif str == "Action"
	  return "Anwendungswissen"
	elsif str == "InstructionalKnowledge"
	  return "Handlungswissen"
        else str == "Orientation"
	  return "Orientierungswissen"
	end
      end  

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        admin_client = FreshupClient::Soap::AdminInterfaceClient.new
        @auth.provided? && @auth.basic? && @auth.credentials && admin_client.authenticate(credentials)
      end

    end
    
    before do
      protected!
      
      @admin_client = FreshupClient::Soap::AdminInterfaceClient.new
      @user_client = FreshupClient::Soap::UserInterfaceClient.new
      @communication_client = FreshupClient::Soap::CommunicationInterfaceClient.new
      @task_client = FreshupClient::Soap::TaskClient.new
      @account = credentials
    end

    
    get '/auth' do
      credentials.to_s
    end
    
    get '/home' do
      haml "/admin/home".to_sym
    end           

            
    get '/' do
      redirect url_for '/admin/home'
      #redirect url_for '/admin/spielsteuerung'
      #redirect url_for '/adminView/admin_ernennen'
    end

    post '/game/start' do
      answer = @admin_client.start_game(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Das Spiel wurde gestartet. Es befindet sich jetzt in der Spielphase.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer den Spielstart.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "NOCONNECTION")
        flash[:error] = 'Es konnte keine Verbindung zum AufgabenServer hergestellt werden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Spielstarten vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Spielstarten.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
      #redirect "#{request.script_name}/"
    end
    
    post '/game/end' do
      answer = @admin_client.end_game(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Das Spiel wurde beendet.  Es befindet sich jetzt in der Nachbereitungsphase.'
        redirect url_for '/admin/spielsteuerung'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Beenden des Spiels.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Spielbeenden vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Spielbeenden.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
      #redirect "#{request.script_name}/"
    end

    post '/game/restart' do
      answer =@admin_client.restart_game(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Die Datenbank wurde geleert, das Spiel kann neu beginnen.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Leeren der Datenbank.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Leeren der Datenbank vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Leeren der Datenbank.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/game/back_login' do
      answer =@admin_client.change_to_login_phase(@account)
      if (answer == true)
        flash[:info] = 'Das Spiel befindet sich wieder in der Login-Phase.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das wechseln in die Login-Phase.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum wechseln in die Login-Phase vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim wechseln in die Login-Phase.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/group/size' do
      max_group_size = params[:max_group_size]
      answer = @admin_client.set_max_group_size(@account, max_group_size)
      if (answer == true)
        flash[:info] = 'Die Gruppengroesse wurde geaendert.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum aendern der Gruppengroesse.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Gruppengroesseaendern vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Gruppengroesseaendern.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/max/interaction' do
      max_interaction = params[:max_interaction]
      answer = @admin_client.set_max_interactions(@account, max_interaction)
      if (answer == true)
        flash[:info] = 'Die Aufgabenanzahl wurde geaendert.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum aendern der Aufgabenanzahl.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aendern der Aufgabenanzahl vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Aendern der Aufgabenanzahl.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/game/recalculate_points' do
      answer = @admin_client.recalculate_points(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Punkte werden neu berechnet'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Neuberechnen der Punkte'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Berechnen der Punkte vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim neu Berechnen der Punkte.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/game/give_interactions_to_all' do
      answer = @admin_client.give_interactions_to_all(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Aufgaben wurden verteilt'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Verteilen der Aufgaben'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Verteilen der Aufgaben vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Verteilen der Aufgaben.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/game/give_interactions_to_all_groups' do
      answer = @admin_client.give_interactions_to_all_groups(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Aufgaben wurden verteilt'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Verteilen der Aufgaben'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Verteilen der Aufgaben vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Verteilen der Aufgaben.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/game/give_interactions_to_all_players' do
      answer = @admin_client.give_interactions_to_all_players(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Aufgaben wurden verteilt'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Verteilen der Aufgaben'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Verteilen der Aufgaben vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Verteilen der Aufgaben.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/exchange/counter' do
      max_exchange_counter = params[:max_exchange_counter]
      answer = @admin_client.set_max_exchange_counter(@account, max_exchange_counter)
      if (answer == true)
        flash[:info] = 'Die Tauchzaehler wurde geaendert.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum aendern des Tauschzaehlers.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aendern des Tauschzaehlers vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Aendern des Tauschzaehlers.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/game/time/start' do
      start_year = params[:start_year]
      start_month = params[:start_month]
      start_day = params[:start_day]
      start_hour = params[:start_hour]
      start_minute = params[:start_minute]

      answer = @admin_client.set_game_start_time(@account, start_year, start_month, start_day, start_hour, start_minute)
      if (answer[:error] == nil)
        flash[:info] = 'Die Spielstartzeit wurden gesetzt.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Aendern der Spielstartzeit.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aendern der Spielzeiten vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGFORMAT")
        flash[:error] = 'Die Spielstartzeit wurd im falschen Format uebergeben.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Aendern der Spielstartzeit.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end ###

    post '/game/time/end' do
      end_year = params[:end_year]
      end_month = params[:end_month]
      end_day = params[:end_day]
      end_hour = params[:end_hour]
      end_minute = params[:end_minute]

      answer = @admin_client.set_game_end_time(@account, end_year, end_month, end_day, end_hour, end_minute)
      if (answer[:error] == nil)
        flash[:info] = 'Die Spielzeiten wurden gesetzt.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Aendern der Spielzeiten.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aendern der Spielzeiten vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGFORMAT")
        flash[:error] = 'Die Spielzeiten wurden im falschen Format uebergeben.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Aendern der Spielzeiten.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end ###
    
    post '/group/create' do
      studycourse = params[:studycourse]
      answer = @admin_client.group_create(@account, studycourse)
      if(answer[:error] == nil)
        flash[:info] = 'Die Gruppe mit der Id '+answer[:int_value]+' wurde erstellt.'
        redirect url_for '/admin/groups'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Erstelle von Gruppen.'
        redirect url_for '/admin/groups'
      elsif (answer[:error] == "WRONGSTUDYCOURSID")
        flash[:error] = 'Die StudiengangId passt nit oder wurde nicht angegeben!'
        redirect url_for 'admin/groups'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Erstellen von Gruppen vorhanden.'
        redirect url_for '/admin/groups'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Erstellen der Gruppe.'
        redirect url_for '/admin/groups'
      else
        flash[:error] = 'Unbekannter Fehler. answer = '
        redirect url_for '/admin/groups'
      end
    end

    post '/groups/interaction' do
      group_id = params[:group_id]

      answer = @admin_client.give_interactions_to_group(@account, group_id)
      if (answer == true)
        flash[:info] = 'Weitere Aufgaben wurden an die Gruppe verteilt.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Verteilen von Aufgaben.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Verteilen von Aufgaben vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Die Gruppe existiert nicht - ihr konnten somit keine Aufgaben gegeben werden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPEMPTY")
        flash[:error] = 'Die Gruppe ist leer. Leeren Gruppen werden keine Aufgaben gegeben.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Verteilen der Aufgaben.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end
    
    get '/groups' do
      max_interactions = @admin_client.get_max_interactions(@account)
      group = @admin_client.group_view_all(@account)
      courses = @admin_client.get_all_study_courses
      haml "admin/groups".to_sym, :locals => {:groups => group, :max_interaction => max_interactions, :game_phase => game_phase, :courses => courses }
    end

    get '/bonus' do
      #courses = @admin_client.get_all_study_courses
      bonus = @admin_client.get_all_bonus_interaction(@account)
      haml "admin/bonus".to_sym, :locals => {:bonus=> bonus }
    end

    get '/player' do
      #courses = @admin_client.get_all_study_courses
      user_without_group = @admin_client.users_without_group(@account)
      if !(user_without_group == "EMPTY")
        puts "Spieler ohne Gruppen #{session[user_without_group]}"
        user_infos = Array.new
        array(user_without_group).each do |p|
          user_infos[p.to_i] = @admin_client.get_user_infos(@account, p)
        end
        haml "admin/player".to_sym, :locals => {:user_without_group => user_without_group, :user_infos => user_infos, :game_phase => game_phase}
      else
        haml "admin/player".to_sym, :locals => {:user_without_group => "nil"}
      end
    end

    post '/player/add/group' do
      group_id = params[:group_id]
      player_id = params[:player_id]
      answer = @admin_client.group_add_player(@account, group_id, player_id);

      if (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Zuordnen von Spielern zu einer Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGFORMAT")
        flash[:error] = 'Falsches Format bei der Bonusaufgabe.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zur Gruppenzuordnung vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "USERNOTEXISTENT")
        flash[:error] = 'Keine Gruppenzuordnung möglich. Der Spieler existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Keine Gruppenzuordnung möglich. Die Gruppe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPFULL")
        flash[:error] = 'Keine Gruppenzuordnung möglich. Die Gruppe ist schon voll.'
        redirect url_for '/admin/'
      elsif (answer == "ALREADYLOCKED")
        flash[:error] = 'Keine Gruppenzuordnung möglich. Die Gruppe ist gesperrt.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Allgemeiner Fehler beim Zuordnen der Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == true)
        flash[:info] = 'Der Spieler wurde der Gruppe zugeoordnet.'
        redirect url_for '/admin/player'
     else
       flash[:error] = 'Fehler beim Zuordnen der Gruppe.'
        redirect url_for '/admin/'
      end
    end

    get '/external_news' do
      #news = @admin_client.external_news(@account)
      news = @communication_client.get_external_news
      puts "News"
      puts news
      haml "admin/external_news".to_sym, :locals => {:news=> news}
    end

    get '/internal_news' do
      news = @admin_client.read_internal_news(@account)
      haml "admin/internal_news".to_sym, :locals => {:news=> news}
    end

    post '/bonus' do
      username = @account[:username]
      password = @account[:password]
      start_date_hour = params[:start_date_hour]
      start_date_minute = params[:start_date_minute]
      start_date_day = params[:start_date_day]
      start_date_month = params[:start_date_month]
      start_date_year = params[:start_date_year]

      solvable_since_hour = params[:solvable_since_hour]
      solvable_since_minute = params[:solvable_since_minute]
      solvable_since_day = params[:solvable_since_day]
      solvable_since_month = params[:solvable_since_month]
      solvable_since_year = params[:solvable_since_year]

      end_date_hour = params[:end_date_hour]
      end_date_minute = params[:end_date_minute]
      end_date_day = params[:end_date_day]
      end_date_month = params[:end_date_month]
      end_date_year = params[:end_date_year]

      interaction_id = params[:interaction_id]
      
      answer = @admin_client.give_bonus_interaction_to_all(username,  password, interaction_id,
        start_date_hour, start_date_minute, start_date_day, start_date_month, start_date_year,
        solvable_since_hour, solvable_since_minute, solvable_since_day, solvable_since_month, solvable_since_year,
        end_date_hour, end_date_minute, end_date_day, end_date_month, end_date_year)
      if (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Verteilen von Bonusaufgaben.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGFORMAT")
        flash[:error] = 'Falsches Format bei der Bonusaufgabe.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer[:error] == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Verteilen der Bonusaufgaben vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Verteilen der Bonusaufgaben.'
        redirect url_for '/admin/'
      else
        flash[:info] = 'Die Bonusaufgabe wurde an die Gruppen verteilt.'
        puts "Antworten"
        puts answer[:item]
        redirect url_for '/admin/'
      end      
    end

    post '/rallye' do
      username = @account[:username]
      password = @account[:password]
      deckname = params[:deckname]
      answer = @admin_client.give_rallye_deck_to_all(username,  password, deckname)

      if (answer[:item] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Verteilen von Rallyedecks.'
        redirect url_for '/admin/'
      elsif (answer[:item] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Verteilen des Rallyedecks vorhanden.'
        redirect url_for '/admin/'
      elsif (answer[:item] == "ERROR")
        flash[:error] = 'Fehler beim Verteilen des Rallyedecks.'
        redirect url_for '/admin/'
      else
        flash[:info] = 'Das Rallyedeck '+deckname+' wurde an die Gruppen verteilt.'
        redirect url_for '/admin/'
      end
    end

    get '/rallye' do
      rallye = @admin_client.get_all_rallye_decks(@account)
      haml "admin/rallye".to_sym, :locals => {:rallye => rallye}
    end

    get '/spielsteuerung' do
      game_config = @admin_client.get_game_config(@account)
      haml "admin/spielsteuerung".to_sym, :locals => {:game_config => game_config}
    end

    get '/mail' do
      player_tmp = @admin_client.get_all_player(@account)
      if (player_tmp[:error] == nil)
        player = player_tmp[:player]
        haml "admin/mail".to_sym, :locals => {:player => player}
      else
        player = "Fehler beim Abrufen der Spieler"
        flash[:error] = 'Fehler beim Abrufen aller Spieler'
      end
    end

    post '/mail/send' do
      
      subject = params[:subject]
      message = params[:message]
      if params[:player_user_ids].empty?
        flash[:error] = "Bitte einen Empfänger angeben!"
        redirect url_for '/admin/mail'
      else
        playeruser_ids = (params[:player_user_ids]).values
        if params[:bcc] == "accept"
          with_bcc = true
        else
          with_bcc = false
        end
        answer = @admin_client.mail_to(@account, playeruser_ids, subject, message, with_bcc)
        if (answer[:error] == nil)
          flash[:info] = 'Die E-Mail wurde versendet.'
          redirect url_for '/admin/'
        elsif (answer[:error] == "USERNOTEXIST")
          flash[:error] = 'Fehler beim E-Mail Versand. Der E-Mail Empfänger existiert nicht.'
          redirect url_for '/admin/'
        elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
          flash[:error] = 'Keine Berechtigung zum Senden der E-Mail vorhanden.'
          redirect url_for '/admin/'
        elsif (answer[:error] == "WRONGFORMAT")
          flash[:error] = 'Falsches Format beim Senden der E-Mail.'
          redirect url_for '/admin/'
        elsif (answer[:error] == "ERROR")
          flash[:error] = 'Fehler beim Senden der e-Mail.'
          redirect url_for '/admin/'
        else
          flash[:error] = 'Fehler beim Senden der e-Mail.'
          redirect url_for '/admin/'
        end
      end
    end

    get '/ranking' do
      ranking        = @admin_client.get_ranking_all(@account)
      group_members = Hash.new      
        array(ranking).each do |p|
          group_members[p[:group_id].to_i] = @admin_client.group_view_members_specific(@account, p[:group_id])

        end

      haml :"admin/ranking", :locals => {
        :ranking        => array(ranking), :members => group_members
      }
    end

    get '/logout' do
      delete(credentials)
      delete(@account)
      redirect url_for '/'      
    end

    post '/external/news' do
      text = params[:extern_news_text]

      answer = @admin_client.add_one_external_news(@account, text)
      if (answer[:error] == nil)
        flash[:info] = 'Die externe News wurde geschrieben.'
        redirect url_for '/admin/external_news'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Schreiben der externen News.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/internal/news' do
      text = params[:internal_news_text]
      answer = @admin_client.add_one_internal_news(@account, text)
      if (answer[:error] == nil)
        flash[:info] = 'Die interne News wurde geschrieben.'
        redirect url_for '/admin/internal_news'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Schreiben der internen News.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/external/news/delete/one' do
      delete_date = Time.parse(params[:delete_date])

      answer = @admin_client.delete_one_external_news(@account, date_to_java(delete_date))
      if (answer[:error] == nil)
        flash[:info] = 'Die externe News wurde gelöscht.'
        redirect url_for '/admin/external_news'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Löschen der externen News.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "NOTADMIN" or answer[:error] == "WRONGADMIN")
        flash[:error] = 'Keine Berechtigung zum Löschen der externen Nachrichten.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/internal/news/delete/one' do
      delete_date = Time.parse(params[:delete_date])

      answer = @admin_client.delete_one_internal_news(@account, date_to_java(delete_date))
      if (answer[:error] == nil)
        flash[:info] = 'Die interne News wurde gelöscht.'
        redirect url_for '/admin/internal_news'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Löschen der internen News.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "NOTADMIN" or answer[:error] == "WRONGADMIN")
        flash[:error] = 'Keine Berechtigung zum Löschen der internen Nachrichten.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/external/news/delete' do
      answer = @admin_client.delete_all_external_news(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Alle externen News wurden gelöscht.'
        redirect url_for '/admin/external_news'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Löschen der externen News.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "NOTADMIN" or answer[:error] == "WRONGADMIN")
        flash[:error] = 'Keine Berechtigung zum Löschen der externen Nachrichten.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/internal/news/delete' do
      answer = @admin_client.delete_all_internal_news(@account)
      if (answer[:error] == nil)
        flash[:info] = 'Alle internen News wurden gelöscht.'
        redirect url_for '/admin/internal_news'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Löschen der internen News.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "NOTADMIN" or answer[:error] == "WRONGADMIN")
        flash[:error] = 'Keine Berechtigung zum Löschen der internen Nachrichten.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    ##############################
    # spezielle Gruppe Anzeigen  #
    ##############################

    get '/group/:group_id' do
      render_group params[:group_id]
    end

    def render_group group_id
      #redirect url_for '/logout' unless session
      members = @admin_client.group_view_members_specific(@account, group_id)
      rank = @admin_client.get_group_rank(@account, group_id)
        
      haml "admin/group".to_sym, :locals => {:group_id => group_id, :members => members, :rank => rank}
    end

    post '/group/interaction/give' do
      group_id = params[:group_id]
      interaction_id = params[:interaction_id]
      answer = @admin_client.group_give_card(@account, group_id, interaction_id)
      if (answer == true)
        flash[:info] = 'Die Aufgbae wurde der Gruppe als richtig gelöst markiert.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Markieren einer Aufgaben als richtig gelöst.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aufgabe als richtig gelöst zu markieren.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Die Gruppe existiert nicht - ihr kann somit keine Aufgaben als richtig gelöst markiert werden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPEMPTY")
        flash[:error] = 'Die Gruppe ist leer. Leeren Gruppen können keine Aufgaben als richtig gelöst markiert werden.'
        redirect url_for '/admin/'
      elsif (answer == "TASKNOTEXISTENT")
        flash[:error] = 'Die ID der Aufgabe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "ALREADYHELD")
        flash[:error] = 'Die Aufgabe wurde von der Gruppe schon richtig gelöst.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Markieren der Aufgaben als richtig gelöst.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/group/wrong_attempts/decrement' do
      group_id = params[:group_id]
      number = params[:decrement_wrong_attempts]
      answer = @admin_client.decrement_wrong_attempts(@account, group_id, number)

       if (answer[:error] == nil)
        flash[:info] = 'Die Fehlverusche wurde um '+number+' verringert.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Ändern der Fehlversuche.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Ändern der Fehlversuche'
        redirect url_for '/admin/'
      elsif (answer[:error] == "WRONGATTEMPTSTOLOW")
        flash[:error] = 'Die Fehlversuche können nicht um '+number+' verringert werden.'
        redirect url_for '/admin/'
      elsif (answer[:error] == "ERROR")
        flash[:error] = 'Fehler beim Ändern des Fehlversuche'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end


    post '/group/interaction/take' do
      group_id = params[:group_id]
      interaction_id = params[:interaction_id]
      answer = @admin_client.group_take_card(@account, group_id, interaction_id)
      if (answer == true)
        flash[:info] = 'Die Aufgbae wurde der Gruppe als falsch gelöst markiert.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Markieren einer Aufgaben als falsch gelöst.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aufgabe als flasch gelöst zu markieren.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Die Gruppe existiert nicht - ihr kann somit keine Aufgaben als flasch gelöst markiert werden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPEMPTY")
        flash[:error] = 'Die Gruppe ist leer. Leeren Gruppen können keine Aufgaben als falsch gelöst markiert werden.'
        redirect url_for '/admin/'
      elsif (answer == "TASKNOTEXISTENT")
        flash[:error] = 'Die ID der Aufgabe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "NOTHELD")
        flash[:error] = 'Die Aufgabe wurde von der Gruppe noch nicht richtig gelöst und kann somit nicht entfernt werden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Markieren der Aufgaben als falsch gelöst.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end

    post '/group/interaction/take' do
      group_id = params[:group_id]
      interaction_id = params[:interaction_id]
      answer = @admin_client.group_take_card(@account, group_id, interaction_id)
      if (answer == true)
        flash[:info] = 'Die Aufgbae wurde der Gruppe als falsch gelöst markiert.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase zum Markieren einer Aufgaben als falsch gelöst.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Aufgabe als flasch gelöst zu markieren.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Die Gruppe existiert nicht - ihr kann somit keine Aufgaben als flasch gelöst markiert werden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPEMPTY")
        flash[:error] = 'Die Gruppe ist leer. Leeren Gruppen können keine Aufgaben als falsch gelöst markiert werden.'
        redirect url_for '/admin/'
      elsif (answer == "TASKNOTEXISTENT")
        flash[:error] = 'Die ID der Aufgabe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "NOTHELD")
        flash[:error] = 'Die Aufgabe wurde von der Gruppe noch nicht richtig gelöst und kann somit nicht entfernt werden.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Fehler beim Markieren der Aufgaben als falsch gelöst.'
        redirect url_for '/admin/'
      else
        flash[:error] = 'Unbekannter Fehler.'
        redirect url_for '/admin/'
      end
    end
    
    post '/group/remove/player' do
      group_id = params[:group_id]
      player_id = params[:player_id]
      answer = @admin_client.group_remove_player(@account, group_id, player_id)

      if (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Entfernen von Spielern aus einer Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Entfernen von Spielern aus Gruppen vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "USERNOTEXISTENT")
        flash[:error] = 'Keine Entfernen aus der Gruppe möglich. Der Spieler existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Keine Entfernen aus der Gruppe möglich. Die Gruppe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "USERNOTINGROUP")
        flash[:error] = 'Keine Entfernen aus der Gruppe möglich. Der Spieler ist nicht in der Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Allgemeiner Fehler beim Entfernen des Spielers aus der Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == true)
        flash[:info] = 'Der Spieler wurde aus der Gruppe entfernt.'
        redirect url_for '/admin/'
     else
       flash[:error] = 'Fehler beim Entfernen aus  der Gruppe!.'
        redirect url_for '/admin/'
      end
    end

    post '/group/disable' do
      group_id = params[:group_id]
      answer = @admin_client.group_disable(@account, group_id)

      if (answer == true)
        flash[:info] = 'Die Gruppe wurde gesperrt.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Sperren einer Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Sperren einer Gruppen vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Keine Sperren der Gruppe möglich. Die Gruppe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "ALREADYLOCKED")
        flash[:error] = 'Keine Sperren der Gruppe möglich. Die Gruppe ist bereits gesperrt.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Allgemeiner Fehler beim Sperren der Gruppe.'
        redirect url_for '/admin/'
     else
       flash[:error] = 'Fehler beim Sperren der Gruppe!.'
        redirect url_for '/admin/'
      end
    end

    post '/group/enable' do
      group_id = params[:group_id]
      answer = @admin_client.group_enable(@account, group_id)

      if (answer == true)
        flash[:info] = 'Die Gruppe wurde entsperrt.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGGAMECYCLE")
        flash[:error] = 'Falsche Spielphase fuer das Entsperren einer Gruppe.'
        redirect url_for '/admin/'
      elsif (answer == "WRONGADMIN" || answer == "NOTADMIN")
        flash[:error] = 'Keine Berechtigung zum Entsperren einer Gruppen vorhanden.'
        redirect url_for '/admin/'
      elsif (answer == "GROUPNOTEXISTENT")
        flash[:error] = 'Keine Entsperren der Gruppe möglich. Die Gruppe existiert nicht.'
        redirect url_for '/admin/'
      elsif (answer == "NOTLOCKED")
        flash[:error] = 'Keine Entsperren der Gruppe möglich. Die Gruppe ist nicht gesperrt.'
        redirect url_for '/admin/'
      elsif (answer == "ERROR")
        flash[:error] = 'Allgemeiner Fehler beim Entsperren der Gruppe.'
        redirect url_for '/admin/'
     else
       flash[:error] = 'Fehler beim Entsperren der Gruppe!.'
        redirect url_for '/admin/'
      end
    end


    ###
    def get_session
      ''
    end


    # helper functions
    def array(arg)
      return [] unless arg
      return [arg] unless arg.is_a? Array
      arg
    end

    def print_date date
      (date.respond_to? :strftime) ? date.strftime("%d.%m.%Y") : date.to_s
    end

    def print_date_with_time date
      (date.respond_to? :strftime) ? date.strftime("%d.%m.%Y um %k:%M Uhr") : date.to_s
    end

    def date_to_java date
      (date.respond_to? :strftime) ? date.strftime("%a %b %d %k:%M:%S CEST %Y") : date.to_s
    end

    def is_open_test
      @admin_client.is_open_test()
    end

    def registration_phase
      "LOGIN" == @admin_client.get_game_phase()
    end

    def summary_phase
      is_summary_phase = false
      if(@admin_client.get_game_phase() == 'SUMMARY')
        is_summary_phase = true
      end
    end

    def game_phase
      is_game_phase = false
      if(@admin_client.get_game_phase() == 'GAME')
        is_game_phase = true
      end
    end

    def preparation_phase
      is_preparation_phase = false
      if(@admin_client.get_game_phase() == 'PREPARATION')
        is_preparation_phase = true
      end
    end

    ############################################
    #AdminView Verlinkungen                    #
    ############################################
    
    
    get '/admin_ernennen' do            
      @course = @task_client.get_all_courses
      haml "/admin/admin_ernennen".to_sym     
    end
    
    post '/admin_ernennen' do
    @course = @task_client.get_all_courses[:item]
      if params[:wpassword] == params[:password]
	if params[:course] == nil
	  params[:course] = ""
	end  
	newAdmin = {:username => params[:username], :password => params[:password], :rank => params[:rang], :course => params[:course]}
	status = @task_client.create_new_admin(@account,newAdmin)
        p"#{status}"
      else 
	flash[:error] = "Passwort stimmt nicht überein"
	redirect url_for '/admin/admin_ernennen'
      end
      haml "/admin/home".to_sym
    end
    
    get '/admin_loeschen' do
      @admin_liste = {} 
      haml "/admin/admin_loeschen".to_sym     
    end
    
    post '/admin_loeschen' do
      @admin_liste = @task_client.get_all_admins(params[:username],params[:password])[:admins]
      if (params[:adminUser] != nil and params[:adminUser] != "")
	@task_client.delete_admin(@account,params[:adminUser])
	redirect url_for '/admin/home'
      end
      haml "/admin/admin_loeschen".to_sym
    end

    get '/frage_erstellen' do
      session[:kartenID] = nil
      haml "/admin/frage_erstellen".to_sym
    end   

    get '/adminView/GPSInteraction' do
      haml "/adminView/GPSInteraction".to_sym
    end    

    get '/InlineChoiceInteraction' do
        @decks = @task_client.get_all_decks[:item]
        @check_type = @task_client.get_all_check_type[:item]      
        @anzahlAntworten = 0
      if session[:kartenID] != nil
        @karte = @task_client.get_interaction(session[:kartenID])
	@anzahlAntworten = @karte[:choices].length
      else
	@karte = {:id => "", :description => "", :title => "", :deck => {:id => "", :name => ""}, :valid_attempt_count => "", :check_type => {:id =>"",:name=>""},:time_solved=>"",:times_not_solved=>"",:is_deactivated=>"",:is_only_given_by_admin=>"",:effort=>"",:image=>"",:prompt=>""}
      end	
	
      haml "/admin/InlineChoiceInteraction".to_sym
    end    

    get '/adminView/MatchInteraction' do
      haml "/adminView/MatchInteraction".to_sym
    end    

    get '/MultipleChoiceFrage' do      
      #frage = {:id => "", :description => "", :title => "", :deck => {:id => "16", :name => "", :group_deck =>false}, :valid_attempt_count => "2", :check_type => {:id =>"7",:name=>""},:time_solved=>"0",:times_not_solved=>"0",:is_deactivated=>false,:is_only_given_by_admin=>false,:effort=>"1",:image=>"",:prompt=>"", :courses =>{:id=>"12"}}
      #@karte = @task_client.create_interaction(@account,frage)
      #@karte = @task_client.get_interaction("73")
      @decks = @task_client.get_all_decks[:item]
      @check_type = @task_client.get_all_check_type[:item]      
#30.05
      @courses = @task_client.get_all_courses[:item]
      @anzahlAntworten = 0
     
      if session[:kartenID] != nil 
        #was soll das?
	#@karte = {:choices => []}
        @karte = @task_client.get_interaction(session[:kartenID])      
        @karte[:type_name] = get_type_name(@karte[:type])
#wenn frage editieren, und anzahl ungleich choices...reagieren!!
	@anzahlAntworten = @karte[:choices].length
      else
	@karte = {:id => "", :description => "", :title => "", :deck => {:id => "", :name => ""}, :valid_attempt_count => "", :check_type => {:id =>"",:name=>""},:time_solved=>"",:times_not_solved=>"",:is_deactivated=>"",:is_only_given_by_admin=>"",:effort=>"",:image=>"",:prompt=>""}
      end
      #p "#{@karte}"
      haml "/admin/MultipleChoiceFrage".to_sym
    end    

    get '/OrderInteraction' do
      @decks = @task_client.get_all_decks[:item]
      @check_type = @task_client.get_all_check_type[:item]      
      @anzahlAntworten = 0
#kommt von frage_editieren
      if session[:kartenID] != nil 
        #was soll das
	#@karte = {:choices => []}
        @karte = @task_client.get_interaction(session[:kartenID])      
        #wenn frage editieren, und anzahl ungleich choices...reagieren!!
	@anzahlAntworten = @karte[:choices].length
#kommt von frage_erstellen
      else
	@karte = {:id => "", :description => "", :title => "", :deck => {:id => "", :name => ""}, :valid_attempt_count => "", :check_type => {:id =>"",:name=>""},:time_solved=>"",:times_not_solved=>"",:is_deactivated=>"",:is_only_given_by_admin=>"",:effort=>"",:image=>"",:prompt=>""}
      end
      haml "/admin/OrderInteraction".to_sym
    end    

    get '/SelectPointInteraction' do
      @decks = @task_client.get_all_decks[:item]
      @check_type = @task_client.get_all_check_type[:item]      
#kommt von frage_editieren
      if session[:kartenID] != nil 
        #was soll das
	#@karte = {:choices => []}
        @karte = @task_client.get_interaction(session[:kartenID])      
#kommt von frage_erstellen
      else
	@karte = {:id => "", :description => "", :title => "", :deck => {:id => "", :name => ""}, :valid_attempt_count => "", :check_type => {:id =>"",:name=>""},:time_solved=>"",:times_not_solved=>"",:is_deactivated=>"",:is_only_given_by_admin=>"",:effort=>"",:image=>"",:prompt=>""}
      end
      #p "#{session[:kartenID]}"            
      #p"#{@karte}"
      haml "/admin/SelectPointInteraction".to_sym
    end    

    get '/SingleChoiceFrage' do
      @decks = @task_client.get_all_decks[:item]
      @check_type = @task_client.get_all_check_type[:item]      
      @anzahlAntworten = 0
#kommt von frage_editieren
      if session[:kartenID] != nil 
        #was soll das
	#@karte = {:choices => []}
        @karte = @task_client.get_interaction(session[:kartenID])      
        #wenn frage editieren, und anzahl ungleich choices...reagieren!!
	@anzahlAntworten = @karte[:choices].length
#kommt von frage_erstellen
      else
	@karte = {:id => "", :description => "", :title => "", :deck => {:id => "", :name => ""}, :valid_attempt_count => "", :check_type => {:id =>"",:name=>""},:time_solved=>"",:times_not_solved=>"",:is_deactivated=>"",:is_only_given_by_admin=>"",:effort=>"",:image=>"",:prompt=>""}
      end
      #p "#{session[:kartenID]}"      
      haml "/admin/SingleChoiceFrage".to_sym
    end    
    
    get '/TextEntryInteraction' do
      @decks = @task_client.get_all_decks[:item]
      @check_type = @task_client.get_all_check_type[:item]      
#kommt von frage_editieren
      if session[:kartenID] != nil 
        #was soll das
	#@karte = {:choices => []}
        @karte = @task_client.get_interaction(session[:kartenID])      
#kommt von frage_erstellen
      else
	@karte = {:id => "", :description => "", :title => "", :deck => {:id => "", :name => ""}, :valid_attempt_count => "", :check_type => {:id =>"",:name=>""},:time_solved=>"",:times_not_solved=>"",:is_deactivated=>"",:is_only_given_by_admin=>"",:effort=>"",:image=>"",:prompt=>""}
      end
      #p "#{session[:kartenID]}"      
      haml "/admin/TextEntryInteraction".to_sym
    end    
    
    post '/TextEntryInteractionAntwort' do
#Antworten werden nicht richtig übergeben, auch in MultipleChoiceFrageAntwort.haml each-Schleife übergibt nur das letzte Argument
      @antwort = params
      @pattern = @task_client.get_all_pattern_masks[:item]
      @antwort.each {|key,value| 
	if (value == "")
	  @antwort.delete(key)
	end
      }
      @karte = @task_client.get_interaction(params[:id])
      @pattern_mask = @karte[:pattern_mask]
      #p"#{@pattern}"
      #p"#{@correctAntwort}"
      #p "#{@karte}"
      haml "/admin/TextEntryInteractionAntwort".to_sym
    end        
    
    get '/adminView/Antwort' do
      haml "/adminView/Antwort".to_sym
    end    
    
    get '/adminView/Antwort1' do
      haml "/adminView/Antwort1".to_sym
    end    
    
    get '/adminView/Antwort2' do
      haml "/adminView/Antwort2".to_sym
    end    
    
    post '/SingleChoiceFrageAntwort' do
#Antworten werden nicht richtig übergeben, auch in MultipleChoiceFrageAntwort.haml each-Schleife übergibt nur das letzte Argument
      if (params[:count] != nil) and (params[:count] != "")
        @correctAntwort = [@task_client.get_associated_solution(params[:id])[:correct_choices]]	  
      end
      @antwort = params
#wenn frage editieren, und anzahl ungleich choices...reagieren!!
      @antwort.each {|key,value| 
	if (value == "")
	  @antwort.delete(key)
	end
      }
      @karte = @task_client.get_interaction(params[:id])
      #p"#{@karte}"
      #p"#{@correctAntwort}"
      haml "/admin/SingleChoiceFrageAntwort".to_sym
    end    

    get '/adminView/GPSInteractionAntwort' do

      haml "/adminView/GPSInteractionAntwort".to_sym
    end    

    get '/MultipleChoiceFrageAntwort' do      
#Antworten werden nicht richtig übergeben, auch in MultipleChoiceFrageAntwort.haml each-Schleife übergibt nur das letzte Argument
      @karte = @task_client.get_interaction(params[:id])
      params["CheckType"] = @task_client.get_check_type(params[:check_type])
      params.delete("check_type")
      params["Deck"] = @task_client.get_deck(params[:deck])
      params.delete("deck")
      params["Course"] = @task_client.get_course(params[:courses])
      params.delete("courses")
      if (params[:count] != nil) and (params[:count] != "")
        @correctAntwort = @task_client.get_associated_solution(params[:id])[:correct_choices]	  
      end
      @antwort = params
#wenn frage editieren, und anzahl ungleich choices...reagieren!!
      @antwort.each {|key,value| 
	if (value == "")
	  @antwort.delete(key)
	end
      }
      session[:interaction] = {}
      session[:interaction]= session[:interaction].merge(params)
      #p"#{@correctAntwort}"
      haml "/admin/MultipleChoiceFrageAntwort".to_sym
    end    

    post '/MultipleChoiceFrageAntwort' do
      session[:interaction].delete("count")
      antworten = {"Choices" => {}}
      antworten["Choices"] = params[:antworten]
      antworten["Choices"].each_with_index do |key,i|
	antworten["Choices"][i] = {"TemporaryID" => "#{i}", "Text" => key}
      end
      #shuffle, MaxChoices, MinChoices, Choices
      attributes = {:attributes! => {"Interaction" => {"Choices" => {"xsi:type" => "tns:unsavedTextChoice"},"xsi:type" => "tns:choiceInteraction"}, "Solution" => {"CorrectChoices" => {"xsi:type" => "tns:unsavedTextChoice"},"xsi:type" => "tns:choiceInteractionSolutionData"} }}
      
      count = antworten["Choices"].length
      
      correctAntwort= Array.new
      params.each do |key,value|
	if value == "w"
	  i = key.to_i
	  correctAntwort = correctAntwort<<(antworten["Choices"][i])
	end
      end
      #session[:interaction["IsDeactivated"]]= to_boolean(session[:interaction["IsDeactivated"]])
      solution = {"Solution" => {"CorrectChoices" => correctAntwort}}
      item = {"Interaction" => session[:interaction].merge(antworten.merge({"MaxChocies" => count}.merge({"MinChoices" => correctAntwort.length})))} 
      item = item.merge(solution.merge(attributes))
      #end
      karte = @task_client.get_interaction("73")
      #correctAntwort = @task_client.get_associated_solution("73")
      #p"#{correctAntwort}"
      #p"#{item}"
      item["Interaction"].delete("id")
      #p"#{item}"
      x = @task_client.create_interaction(@account,item)
      p "#{x}"
      #p"#{session[:interaction]}"
=begin      check_type = {"ID" => 2, "Name" => "nie"} 
      deck = {"ID" => 16, "Name" => "Uni", "groupDeck" => false} 
      course = {"ID" => 12, "Name" => "allgemein"} 
      interaction= {"Description" => "Hinweis fuer Admin", "Image" => "URL","Title" => "Mein Titel 1", "CheckType" => check_type, "Effort" => 1, "IsDeactivated" => false,"IsOnlyGivenByAdmin" => false, "Type" => "Fact", "Deck" => deck, "ValidAttemptCount" => 3, "Courses" => course, "ToleranceRadius" => 0.2, "Prompt" => "Fragestellung"}

      solution = { "CorrectLatitude" =>52.4079, "CorrectLongitude" => 12.9753}

      item = {"Interaction" => interaction, "Solution" => solution, :attributes! => { "Interaction" => {  "xsi:type" => "tns:gpsInteraction"},"Solution" => {'xsi:type' => 'tns:gpsInteractionSolutionData'} }}
      #p"#{item}"
      x = @task_client.create_interaction(@account,item)
=end      p"#{x}"
      
    end
    
    post '/InlineChoiceInteractionAntwort' do
#Antworten werden nicht richtig übergeben, auch in MultipleChoiceFrageAntwort.haml each-Schleife übergibt nur das letzte Argument
      if (params[:count] != nil) and (params[:count] != "")
        @correctAntwort = [@task_client.get_associated_solution(params[:id])[:correct_choice]]	  
      end
      @antwort = params
#wenn frage editieren, und anzahl ungleich choices...reagieren!!
      @antwort.each {|key,value| 
	if (value == "")
	  @antwort.delete(key)
	end
      }
      @karte = @task_client.get_interaction(params[:id])
      #p"#{@correctAntwort}"
      haml "/admin/InlineChoiceInteractionAntwort".to_sym
    end    
    
    get '/adminView/MatchInteractionAntwort' do
      haml "/adminView/MatchInteractionAntwort".to_sym
    end    

    post '/OrderInteractionAntwort' do
#Antworten werden nicht richtig übergeben, auch in MultipleChoiceFrageAntwort.haml each-Schleife übergibt nur das letzte Argument
      if (params[:antworten] != nil) and (params[:antworten] != "")
      end
      @antwort = params
#wenn frage editieren, und anzahl ungleich choices...reagieren!!
      @antwort.each {|key,value| 
	if (value == "")
	  @antwort.delete(key)
	end
      }
      @karte = @task_client.get_interaction(params[:id])
      #p"#{@karte}"

      haml "/admin/OrderInteractionAntwort".to_sym
    end    

    post '/SelectPointInteractionAntwort' do
      @correctAntwort = @task_client.get_associated_solution(params[:id])
      
      @antwort = params
#wenn frage editieren, und anzahl ungleich choices...reagieren!!
      @antwort.each {|key,value| 
	if (value == "")
	  @antwort.delete(key)
	end
      }
      @karte = @task_client.get_interaction(params[:id])
      #p"#{@correctAntwort}"
      haml "/admin/SelectPointInteractionAntwort".to_sym
    end    

    get '/adminView/TextEntryInteractionAntwort' do
      haml "/adminView/TextEntryInteractionAntwort".to_sym
    end    

    get '/frage_editieren' do
      @suchefrage = {}
      @decks = @task_client.get_all_decks
      @course = @task_client.get_all_courses
      @check_type = @task_client.get_all_check_type      
=begin      @suchefrage = @task_client.view_filtered_interaction(task,false,false)[:item]	
      @suchefrage = @suchefrage + (@task_client.view_filtered_interaction(task,false,true)[:item])
      @suchefrage = @suchefrage + (@task_client.view_filtered_interaction(task,true,false)[:item])
      @suchefrage = @suchefrage.sort_by{|b| b[:title]}          
=end      #p"#{@suchefrage}"
      #p"#{@course}"
      #p"#{@suchefrage}"
      haml "/admin/frage_editieren".to_sym
    end    

    post '/frage_editieren' do
      @decks = @task_client.get_all_decks
      @course = @task_client.get_all_courses
      @check_type = @task_client.get_all_check_type      

      #gibt den gesuchten fragetype zurück, kurze form suchefrage[:item][0].delete(:choices) gibt key :choices zurück     
      if (params[:kartenID] != "" and params[:kartenID] != nil)
        suchefrage = @task_client.get_interaction(params[:kartenID])
	
	suchefrage.delete(:choices)
        if (suchefrage[:"@xsi:type"] == "ns2:choiceInteraction")
	  if (suchefrage[:min_choices] != "1")
	    session[:kartenID] = params[:kartenID]
	    redirect url_for "admin/MultipleChoiceFrage"
	  else
	    session[:kartenID] = params[:kartenID]
	    redirect url_for "admin/SingleChoiceFrage"
	  end 
	elsif (suchefrage[:"@xsi:type"] == "ns2:inlineChoiceInteraction")
	    session[:kartenID] = params[:kartenID]
	    redirect url_for "admin/InlineChoiceInteraction"	    	
	elsif (suchefrage[:"@xsi:type"] == "ns2:orderInteraction")
	    session[:kartenID] = params[:kartenID]
	    redirect url_for "admin/OrderInteraction"	  
	elsif (suchefrage[:"@xsi:type"] == "ns2:textEntryInteraction")
	    session[:kartenID] = params[:kartenID]
	    redirect url_for "admin/TextEntryInteraction"	  
	elsif (suchefrage[:"@xsi:type"] == "ns2:selectPointInteraction")
	    session[:kartenID] = params[:kartenID]
	    redirect url_for "admin/SelectPointInteraction"
	end
      end

      #frage suchen
      suchefrage = {:item => []}      
      if (params[:title] != nil and params[:title] != "")
	a = [@task_client.view_filtered_interaction_simple({"Title" => params[:title]})[:item]]
        unless a.empty?
	  suchefrage[:item] += a
	end  
      end
      if (params[:id] != nil and params[:id] != "")
	b = [@task_client.get_interaction(params[:id])]
        unless b.empty?
	  suchefrage[:item] += b
	end  
      end
      if (params[:deck_id] != nil and params[:deck_id] != "")
	c = @task_client.view_filtered_interaction_simple({"Deck" => {"ID" => params[:deck_id]}})[:item]
        unless c.empty?
	  suchefrage[:item] += c	  
	end
      end
           
      if (params[:group_deck] != nil and params[:group_deck] != "")
	booleanGroupDeck = to_boolean(params[:group_deck])
        d = Array.new
	z = @task_client.get_all_decks
	z = z[:item]
	z.each {|item| 
	  if  booleanGroupDeck == item[:group_deck]
	    d += @task_client.view_filtered_interaction_simple({"Deck" => {"ID" => item[:id]}})[:item]
	  end}
        unless d.empty?
	  suchefrage[:item] += d
	end
      end
      
      if (params[:deck_name] != nil and params[:deck_name] != "")
	e = @task_client.view_filtered_interaction_simple({"Deck" => {"ID" => params[:deck_name]}})[:item]
	suchefrage[:item] += e
      end

      if (params[:course] != nil and params[:course] != "")
	f = @task_client.view_filtered_interaction_simple({"Course" => params[:course]})[:item]
	suchefrage[:item] += f
      end
      if (params[:type] != nil and params[:type] != "")
	g = @task_client.view_filtered_interaction_simple({"Type" => params[:type]})[:item]
	suchefrage[:item] += g
      end
      if (params[:check_type] != nil and params[:check_type] != "")
	h = @task_client.view_filtered_interaction_simple({"CheckType" => {"ID" => params[:check_type]}})[:item]
	suchefrage[:item] += h
      end      
      if (params[:check_id] != nil and params[:check_id] != "")
	i = @task_client.view_filtered_interaction_simple({"CheckType" => {"ID" => params[:check_id]}})[:item]
	suchefrage[:item] += i
     end            
      @suchefrage = suchefrage
      #suchefrage = @task_client.get_interaction("12")
      #p"#{suchefrage}"
      haml "/admin/frage_editieren".to_sym
    end        
    
    get '/adminView/frage_loeschen' do
      haml "/adminView/frage_loeschen".to_sym
    end    


    get '/Spielkarteneinstellung' do
    #wenn nur ein Spieler in der Datenbank ist, ändert sich der Datentyp von Spieler_liste aus dem Array{:player =>[]} wird ein Hash{:player =>{}} und die Seite funktioniert nicht mehr  
      @spieler = []
      @spieler_liste = @admin_client.get_all_player(@account)[:player]            
      @spieler_liste = @spieler_liste.sort_by{|b| b[:last_name]}
      @gruppen_liste = @admin_client.view_all_groups(@account)
      haml "/admin/Spielkarteneinstellung".to_sym
    end   

    get '/admin/home' do
      haml "/admin/home".to_sym
    end       

#gruppensuche fehlt noch!!!!    
    post '/Spielkarteneinstellung' do
      antworttyp = params
      @spieler = []
      if antworttyp[:playerid] != nil
	@spieler_liste = @admin_client.get_all_player(@account)
        count = 0
	@spieler_liste[:player].each_with_index do |key,i|	            
          if antworttyp[:playerid].to_i == key[:player_id].to_i
	    @spieler[count] = @spieler_liste[:player][i]
            count+=1	  
	  end  
	end	
	if @spieler == []
          flash[:error] = "Keine passende Auswahl (Spieler ID) getroffen"
	  redirect url_for '/admin/Spielkarteneinstellung'
        end	  
	haml "/admin/Spielkarteneinstellung".to_sym
      elsif antworttyp[:firstname] != nil             
	@spieler_liste = @admin_client.get_all_player(@account)
        count = 0
	@spieler_liste[:player].each_with_index do |key,i|	            
          if antworttyp[:firstname].to_s == key[:first_name].to_s
	    @spieler[count] = @spieler_liste[:player][i]
	    count+=1
	  end  
	end
	if @spieler == []
          flash[:error] = "Keine passende Auswahl (Vorname) getroffen"
	  redirect url_for '/admin/Spielkarteneinstellung'
        end
	haml "/admin/Spielkarteneinstellung".to_sym
      elsif antworttyp[:lastname] != nil
	@spieler_liste = @admin_client.get_all_player(@account)
        count = 0
	@spieler_liste[:player].each_with_index do |key,i|	            
          if antworttyp[:lastname].to_s == key[:last_name].to_s
	    @spieler[count] = @spieler_liste[:player][i]
	    count+=1
	  end  
	end
	if @spieler == []
          flash[:error] = "Keine passende Auswahl (Nachname) getroffen"
	  redirect url_for '/admin/Spielkarteneinstellung'
        end	  
	haml "/admin/Spielkarteneinstellung".to_sym  
      else
        flash[:error] = "Keine passende Auswahl getroffen"
	redirect url_for '/admin/Spielkarteneinstellung'
      end
    end

    
    post '/SpielkarteneinstellungSpieler' do
      @decks = @task_client.get_all_decks      
      @check_type = @task_client.get_all_check_type
      @course = @task_client.get_all_courses
      @suchefrage = {}      
      @spieler_liste = @admin_client.get_all_player(@account)
      @spieler_liste[:player].each_with_index do |key,i|	            
        if params[:player] == key[:player_id]
	  @auswahlSpieler = @spieler_liste[:player][i]	  
	end  
      end
      if (params[:kartenID] != nil and params[:kartenID] != "")
#Rückgabewerte, können noch behandelt werden.
	@admin_client.give_card_to_player(@account, params[:player], params[:kartenID])
	flash[:info] = "Frage wurde dem Spieler zugeordnet"
	@admin_client.recalculate_points(@account)
	redirect url_for '/admin/home'
      end

      #Frage suche
      #exceptions für falsche eingaben müssen noch in task_client abgefangen werden, auch leere Listen erzeugen Fehler, wenn Datenmenge nicht vorhanden ist!!!!

      suchefrage = {:item => []}      
      if (params[:title] != nil and params[:title] != "")
	a = [@task_client.view_filtered_interaction_simple({"Title" => params[:title]})[:item]]
        unless a.empty?
	  suchefrage[:item] += a
	end  
      end
      if (params[:id] != nil and params[:id] != "")
	b = [@task_client.get_interaction(params[:id])]
        unless b.empty?
	  suchefrage[:item] += b
	end  
      end
      if (params[:deck_id] != nil and params[:deck_id] != "")
	c = @task_client.view_filtered_interaction_simple({"Deck" => {"ID" => params[:deck_id]}})[:item]
        unless c.empty?
	  suchefrage[:item] += c	  
	end
      end
           
      if (params[:group_deck] != nil and params[:group_deck] != "")
	booleanGroupDeck = to_boolean(params[:group_deck])
        d = Array.new
	z = @task_client.get_all_decks
	z = z[:item]
	z.each {|item| 
	  if  booleanGroupDeck == item[:group_deck]
	    d += @task_client.view_filtered_interaction_simple({"Deck" => {"ID" => item[:id]}})[:item]
	  end}
        unless d.empty?
	  suchefrage[:item] += d
	end
      end
      
      if (params[:deck_name] != nil and params[:deck_name] != "")
	e = @task_client.view_filtered_interaction_simple({"Deck" => {"ID" => params[:deck_name]}})[:item]
	suchefrage[:item] += e
      end

      if (params[:course] != nil and params[:course] != "")
	f = @task_client.view_filtered_interaction_simple({"Course" => params[:course]})[:item]
	suchefrage[:item] += f
      end
      if (params[:type] != nil and params[:type] != "")
	g = @task_client.view_filtered_interaction_simple({"Type" => params[:type]})[:item]
	suchefrage[:item] += g
      end
      if (params[:check_type] != nil and params[:check_type] != "")
	h = @task_client.view_filtered_interaction_simple({"CheckType" => {"ID" => params[:check_type]}})[:item]
	suchefrage[:item] += h
      end      
      if (params[:check_id] != nil and params[:check_id] != "")
	i = @task_client.view_filtered_interaction_simple({"CheckType" => {"ID" => params[:check_id]}})[:item]
	suchefrage[:item] += i
     end            
      @suchefrage = suchefrage
      haml "/admin/SpielkarteneinstellungSpieler".to_sym
    end   


  end
    
end 