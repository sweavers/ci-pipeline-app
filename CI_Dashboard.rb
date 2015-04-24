require 'sinatra'
#require 'json'
#require 'pg'
#require 'HTTPClient'
#require 'net/http'
#require 'uri'
#require 'nokogiri'
#require 'cgi'
#require 'socket'
#require 'net/smtp'
require 'sinatra/reloader'
#require_relative "./Marval Soap Requests.rb"
 
set :port, 8088
set :environment, :development
set :server, 'webrick'

class MarvalData
	def initialize
	
	end
	
	def get_lcr_data ( lcr_id )
	
	end	
	
	def get_rfc_data ( rfc_id )
	
	end
end


class DatabaseData
	def initialize 

	end
	
	def get_lcr_contacts ( lcr_id )
	
	end
	
	def get_lcr_information
	
	end
end
 
 
get '/home_month_view' do
	erb :dashboard_month_view
end

get '/home_week_view' do
	erb :dashboard_week_view
end

get '/new_lcr' do
	erb :dashboard_new_lcr
end

get '/new_deployment' do
	erb :dashboard_new_deployment
end




get '/lcr_details' do
	if params["lcr_id"].nil? || params["lcr_id"].empty?
		puts 'WARNING: No lcr_id was entered'
		@lcr_id = 'EMPTY'
		@parameter_missing = true
	else
		@lcr_id = params["lcr_id"]
	end	
	
	if params["rfc_id"].nil? || params["rfc_id"].empty?
		puts 'WARNING: No rfc_id was entered'
		@rfc_id = 'EMPTY'
		@parameter_missing = true
	else
		@rfc_id = params["rfc_id"]
	end	
	
	if @lcr_id != 'EMPTY' && @rfc_id == 'EMPTY'
		marval_object = MarvalAPI.new 
		marval_object.login( "cs027sw" )
		request = marval_object.get_xml_request( @lcr_id )
		@contact_name = request.to_s[/<ContactName>(.*?)<\/ContactName>/, 1]
		
		@contact_name
		@error_message = ''
		erb :LCR_dashboard
	elsif @rfc_id != 'EMPTY' && @lcr_id == 'EMPTY'
		marval_object = MarvalAPI.new 
		marval_object.login( "cs027sw" )
		request = marval_object.get_xml_request( @rfc_id )
		@contact_name = request.to_s[/<ContactName>(.*?)<\/ContactName>/, 1]
		@contact_name = @contact_name.tr(',','')
		
		@error_message = ''
		@contact_name
		erb :RFC_dashboard
	elsif @rfc_id == 'EMPTY' && @lcr_id == 'EMPTY'
		puts 'Please enter LCR or RFC ID'
		@error_message = 'error'
		erb :dashboard_home
	else
		puts 'please only enter either a LCR or RFC, not both.'
		@error_message = 'error'
		erb :dashboard_home
	end
end
























