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
require 'date'
require 'time'
#require_relative "./Marval Soap Requests.rb"

#	border: 2px solid #90C695;


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


class TimeData
	def days_in_month(year, month)
	  Date.new(year, month, -1).day
	end

	def previous_month_name(month)
		previous_month = month - 1
		if previous_month == 0
			previous_month = 12
		end
		previous_month = Time.parse('01.' + previous_month.to_s + '.2015')
		previous_month_name = previous_month.strftime("%b")
	end

	def subsequent_month_name(month)
		subsequent_month = month + 1
		if subsequent_month == 13
			subsequent_month = 1
		end
		subsequent_month = Time.parse('01.' + subsequent_month.to_s + '.2015')
		subsequent_month_name = subsequent_month.strftime("%b")
	end
end


get '/home_month_view' do
	if params["arrow_value"].nil? || params["arrow_value"].empty?
		puts 'WARNING: No year was entered'
		@arrow_value = 'no_value'
	else
		@arrow_value = params["arrow_value"]
	end

	if params["current_month_year"].nil? || params["current_month_year"].empty?
		puts 'WARNING: No current_month_year was entered'
		current_time = Time.now
		first_weekday_number = current_time.strftime("%m%Y")
		@current_month_year = first_weekday_number.to_s
	else
		@current_month_year = params["current_month_year"]
	end

	time_data_obj = TimeData.new

	previous_month_days = []
	subsequent_month_days = []
	previous_month =  0
	previous_month_name =  ''
	subsequent_month_name =  0

	current_month = @current_month_year[0..1].to_i
	current_year = @current_month_year[2..5].to_i

	if @arrow_value == "positive"
		current_month = current_month + 1
		if current_month == 13
			current_year = current_year + 1
			current_month = 1
		end
	elsif @arrow_value == "minus"
		current_month = current_month - 1
		if current_month == 0
			current_year = current_year - 1
			current_month = 12
		end
	end

	subsequent_month_name = time_data_obj.subsequent_month_name(current_month)
	previous_month_name = time_data_obj.previous_month_name(current_month)

	number_of_days = time_data_obj.days_in_month(current_year, current_month)
	firstday_of_month = Time.parse('01.' + current_month.to_s + '.' + current_year.to_s)
	lastday_of_month = Time.parse(number_of_days.to_s + '.' + current_month.to_s + '.' + current_year.to_s)
	first_weekday_number = firstday_of_month.strftime("%w")
	last_weekday_number = lastday_of_month.strftime("%w")
	month_name = firstday_of_month.strftime("%B")

	if first_weekday_number.to_i == 1
		puts 'First day of the month is a Monday'
	else
		previous_month = current_month - 1
		previous_year = current_year
		if previous_month == 0
			previous_year = previous_year - 1
			previous_month = 12
		end

		lastday_of_month = time_data_obj.days_in_month(previous_year, previous_month)
		if first_weekday_number.to_i == 0
			first_weekday_number = 7
		end

		weekday_number = first_weekday_number.to_i - 2
		previous_first = lastday_of_month.to_i - (weekday_number)
		previous_month_days = (previous_first.to_i..lastday_of_month.to_i).to_a
	end

	if last_weekday_number.to_i == 0
		puts 'Last day of the month is a Sunday'
	else
		additional_days = 7 - last_weekday_number.to_i
		subsequent_month_days = (1..additional_days).to_a
	end

	if current_month.to_s.length == 1
		current_month = '0' + current_month.to_s
	end

	@current_month_year = current_month.to_s + current_year.to_s
	@month_year = month_name + ' ' + current_year.to_s
	@previous_month_days = previous_month_days
	@previous_month = previous_month_name.to_s
	@subsequent_month = subsequent_month_name.to_s
	@current_month_days = number_of_days
	@subsequent_month_days = subsequent_month_days
	erb :dashboard_month_view
end



get '/home_week_view' do
	if params["arrow_value"].nil? || params["arrow_value"].empty?
		puts 'WARNING: No year was entered'
		@arrow_value = 'no_value'
	else
		@arrow_value = params["arrow_value"]
	end

	time_data_obj = TimeData.new

	if params["current_monday_month_year"].nil? || params["current_monday_month_year"].empty?
		puts 'WARNING: No current_monday_month_year was entered'
		current_time = Time.now
		weekday_number = current_time.strftime("%w")
		@current_day_month_year = current_time.strftime("%d%m%Y")
		weekday = current_time.strftime("%d")
		if weekday_number.to_i == 1
			monday_month_year = current_time.strftime("%d%m%Y")
			@current_monday_month_year = monday_month_year.to_s
		else
			current_month = @current_day_month_year[2..3].to_i
			current_year = @current_day_month_year[4..7].to_i

			#month_year = current_time.strftime("%m%Y")
			difference = weekday_number.to_i - 1
			weekday = weekday.to_i - difference
			if weekday < 0
				previous_month = current_month - 1
				previous_year = current_year
				if previous_month == 0
					previous_year = previous_year - 1
					previous_month = 12
				end

				lastday_of_month = time_data_obj.days_in_month(previous_year, previous_month)

				weekday = lastday_of_month.to_i - difference
				@current_monday_month_year = weekday.to_s + current_month.to_s + current_year.to_s
			else
				weekday = weekday.to_i - difference
        if weekday.to_s.length == 1
          weekday = "0" + weekday.to_s
        end
        if current_month.to_s.length == 1
          current_month = "0" + current_month.to_s
        end
				@current_monday_month_year = weekday.to_s + current_month.to_s + current_year.to_s
			end
			puts '}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}'
			puts current_month.to_s + current_year.to_s
			puts '>>>>>>>>>> month_year <<<<<<<<<<<<<<'
			puts difference
			puts '>>>>>>>>>> difference <<<<<<<<<<<<<<'
			puts weekday
			puts '>>>>>>>>>> weekday <<<<<<<<<<<<<<'
		end
	else
		@current_monday_month_year = params["current_monday_month_year"]
	end

	puts '+++++++++++++++++++++++++++++++'
	puts @current_monday_month_year
	puts '+++++++++++++++++++++++++++++++'

	current_month = 0
	current_year = 0
	previous_month = 0
	previous_year = 0
	previous_month_days = []
	subsequent_month_days = []

	current_monday = @current_monday_month_year[0..1].to_i
	current_month = @current_monday_month_year[2..3].to_i
	current_year = @current_monday_month_year[4..7].to_i

	plus_six = current_monday+6

	@weekdays = {}
  @weekday_array = []
	@weekday_names = []

  @weekday_names.push("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

  count = -1
	(current_monday..plus_six).each do |day|
		@weekdays[day] = "current"
    count = count + 1
    @weekday_array.push(@weekday_names[count] + ", " + day.to_s)
	end

  puts '[][][][][][][][][][]'
  puts @weekday_array
  puts '[][][][][][][][][][]  weekday_array'
  puts current_month
  puts '[][][][][][][][][][]  current_month'
  puts @weekdays.to_s
  puts '[][][][][][][][][][]  weekdays_hash'

	if @arrow_value == "positive"
		puts '	###########'
		puts '	###########'
		puts '	###########'
		puts current_month
		current_month = current_month + 1
		if current_month == 13
			current_year = current_year + 1
			current_month = 1
		end
		puts '	++++++++++++'
		puts '	++++++++++++'
		puts '	++++++++++++'
		puts current_month
	elsif @arrow_value == "minus"
		current_month = current_month - 1
		if current_month == 0
			current_year = current_year - 1
			current_month = 12
		end
	end

	subsequent_month_name = time_data_obj.subsequent_month_name(current_month)
	previous_month_name = time_data_obj.previous_month_name(current_month)

	puts '########################'
	puts current_year
	puts '--------------------------------'
	puts current_month
	puts '########################'

	time_data_obj = TimeData.new

	number_of_days = time_data_obj.days_in_month(current_year, current_month)

	firstday_of_month = Time.parse('01.' + current_month.to_s + '.' + current_year.to_s)
	month_name = firstday_of_month.strftime("%B")

	@current_monday_month_year
	@month_year = month_name + ' ' + current_year.to_s
  @weekday_array
	@weekdays
	@previous_month = previous_month_name.to_s
	@subsequent_month = subsequent_month_name.to_s
	erb :dashboard_week_view
end



get '/new_lcr' do
	erb :dashboard_new_lcr
end

get '/new_deployment' do
	erb :dashboard_new_deployment
end









=begin

		<div class="calendar_slot_grey_full">
			<div class="calendar_text" align="right">1</div>
			<div class="LCR4_calendar">Some different changes</div>
			<div class="LCR2_calendar">Changes to UI</div>
			<div class="LCR1_calendar">Security changes</div>
			<div class="LCR3_calendar">Map changes</div>
		</div>
		<div class="calendar_slot_grey">
			<div class="calendar_text" align="right">2</div>
		</div>
		<div class="calendar_slot_grey">
			<div class="calendar_text" align="right">3</div>
		</div>

=end


=begin

			if weekday == 3 && time_slot == "20:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR4_calendar_week"><div class="week_calendar_text">Title of some changes</div></div>
				</div>
			<% elsif weekday == 1 && time_slot == "19:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR1_calendar_week">
					<div class="triangle"></div>
					<div class="week_calendar_text_fail"><strike>Security changes</strike></div>
					</div>
				</div>
			<% elsif weekday == 3 && time_slot == "21:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR1_calendar_week">
					<div class="week_calendar_text_fail_2">Security changes</div>
					<img src="fail.png" class="image_format">
					</div>
				</div>
			<% elsif weekday == 5 && time_slot == "02:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR2_calendar_week"><div class="week_calendar_text">Changes to UI</div></div>
				</div>
			<% elsif weekday == 6 && time_slot == "22:00" || weekday == 6 && time_slot == "23:00" || weekday == 6 && time_slot == "00:00"%>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
					<div class="LCR3_calendar_week"><div class="week_calendar_text">Infrastructure changes</div></div>
				</div>
			<% elsif weekday == 5 %>
				<% if time_slot == "19:00" %>
					<div class="week_calendar_slot_bottom">
						<div class="calendar_text" align="right"><%=time_slot%></div>
					</div>
				<% elsif time_slot == "04:00" %>
					<div class="week_calendar_slot_top">
						<div class="calendar_text" align="right"><%=time_slot%></div>
					</div>
				<% else %>
					<div class="week_calendar_slot_today">
						<div class="calendar_text" align="right"><%=time_slot%></div>
					</div>
				<% end %>
			<% elsif weekday == 1 || weekday == 2%>
				<div class="week_calendar_slot_grey">
					<div class="calendar_text" align="right"><%=time_slot%></div>
				</div>
			<% else %>
				<div class="week_calendar_slot">
					<div class="calendar_text" align="right"><%=time_slot%></div>
				</div>
			<% end %>

=end
