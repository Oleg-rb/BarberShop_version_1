#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

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

post '/visit' do

	@user_name  = params[:user_name]
	@phone      = params[:phone]
	@date_time  = params[:date_time]
	@specialist = params[:specialist]
	@color      = params[:color]

	# хеш
	hh = { :user_name  => 'Введите Ваше имя',
		   :phone     => 'Введите номер Вашего телефона',
		   :date_time => 'Введите дату и время' }

	# №1 способ
	# для каждой пары ключ-значение
	#hh.each do |key, value|

		# если параметр пуст
	#	if params[key] == ''
			# переменной error присвоить value из хеша hh
			# (а value из хеша hh - это сообщение об ошибке)
			# т.е. переменной error присвоить сообщение об ошибке
	#		@error = hh[key]

			# вернуть представление visit
	#		return erb :visit
	#	end
	#end

	# №2 способ
		@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

		if @error != ''
			return erb :visit
		end

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
