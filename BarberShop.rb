#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS 
	"Users" 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
		"name" TEXT, 
		"phone" TEXT, 
		"date_stamp" TEXT, 
		"barber" TEXT, 
		"color" TEXT
	)'
end 

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

get '/admin' do
	erb :admin
end

get '/showusers' do
	db = get_db
	@results = db.execute 'select * from Users order by id desc'

	erb :showusers
end

post '/visit' do

	@user_name  = params[:user_name]
	@phone      = params[:phone]
	@date_time  = params[:date_time]
	@specialist = params[:specialist]
	@color      = params[:color]

	hh = { :user_name  => 'Введите Ваше имя',
		   :phone     => 'Введите номер Вашего телефона',
		   :date_time => 'Введите дату и время' }

		@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

		if @error != ''
			return erb :visit
		end

	db = get_db
	db.execute 'insert into Users (name, phone, date_stamp, barber, color) values (?, ?, ?, ?, ?)', [@user_name, @phone, @date_time, @specialist, @color]

	@title = "Спасибо за Ваш выбор, #{@user_name}!"
	@message = "Ваш парикмахер #{@specialist} будет ждать Вас #{@date_time}!"

	file_users = File.open './public/users.txt', 'a'
	file_users.write "User: #{@user_name},   Phone: #{@phone},   Date and time: #{@date_time},   Specialist: #{@specialist},   Color: #{@color}\n"
	file_users.close

	erb :message
end

post '/contacts' do

	@email        = params[:email]
	@user_message = params[:user_message]

	hh = { :email        => 'Введите Ваш емайл',
		   :user_message => 'Введите Ваше сообщение' }

		@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

		if @error != ''
			return erb :contacts
		end

	@title = "Большое спасибо!"
	@message = "<h4>Ваше сообщение очень важно для нас!</h4>
	            <h4>Мы не передаём информацию третьим лицам!</h4>"

	file_contacts = File.open './public/contacts.txt', 'a'
	file_contacts.write "Users_email: #{@email},   Users_message: #{@user_message}\n"
	file_contacts.close

	erb :message
end

post '/admin' do
	@login    = params[:login]
	@password = params[:password]
	@file     = params[:file]

	if @login == 'admin' && @password == 'secret' && @file == 'Посетители'
		@logfile = @file_users
		send_file './public/users.txt'
		erb :create
	elsif @login == 'admin' && @password == 'secret' && @file == 'Контакты'
		@logfile = @file_contacts
		send_file './public/contacts.txt'
		erb :create
	else
		@error ='Access denied'
		erb :admin
	end	
end
