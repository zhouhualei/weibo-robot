# -*- coding: utf-8 -*-
require 'watir-webdriver'

module Robot
  module Weibo
	  class MobileRobot

			# 
			# => Example:
			# => robot = Robot::Weibo::MobileRobot.new("chrome")
			# => robot.logout
			# => robot.goto_login_page
			# => robot.login(username, passwd)
			# => robot.goto_repost_page(weibo_id)
			# => robot.repost("Great")
			# 

	  	attr_accessor :driver, :cookie

	  	WEIBO_MOBILE_LOGIN_URL = "login.weibo.cn/login/?backURL=http%3A%2F%2Fweibo.cn%2F"
	  	WEIBO_MOBILE_LOGOUT_UR = "3g.sina.com.cn/prog/wapsite/sso/loginout.php?backURL=http%3A%2F%2Fweibo.cn%2Fpub%2F%3Fvt%3D&backTitle=%D0%C2%C0%CB%CE%A2%B2%A9&vt="
	  	WEIBO_MOBILE_BASE_URL = "weibo.cn/"
	  	
	  	def initialize(browser)
	  		@username = nil
	  		@passwd = nil
	  		@cookie = nil
	  		@driver = case browser
	  			when "firefox"
	  				Watir::Browser.new(:firefox, :profile => 'default')
	  			else 
	  				Watir::Browser.new(:chrome)
	  			end
	  	end

      def logout
        @driver.goto WEIBO_MOBILE_LOGOUT_UR
        sleep 4      	
      end

	  	def goto_login_page
        @driver.goto WEIBO_MOBILE_LOGIN_URL
        sleep 2
	  	end

	  	def login(username, passwd)
	  		@username = username
	  		@passwd = passwd
        @driver.text_field(:name => 'mobile').set(username)
        sleep 1
        @driver.text_field(:type => 'password').set(passwd)
        sleep 1
        @driver.button(:name => 'submit').click
        @cookie = get_cookie
        sleep 5
	  	end

	  	# def go_to_homepage(uid)
	  	# 	@driver.goto("#{WEIBO_MOBILE_BASE_URL}#{uid}")
	  	# 	sleep 3
	  	# end

	  	def goto_repost_page(weibo_id)
	  	#	weibo_id = get_weiboid_for_test if weibo_id.nil?
	  		repost_url = "#{WEIBO_MOBILE_BASE_URL}repost/#{weibo_id}"
	  		p repost_url
	  		@driver.goto repost_url
	  		login(@username, @passwd) if is_login_page?
	  		sleep 5
	  	end

	  	def repost(repost_content)
	  		@driver.text_field(:name => "content").set(repost_content)
	  		sleep 1
	  		@driver.input(:value => '转发').click
	  	end

	  	def get_cookie
        cookie_array = @driver.driver.manage.all_cookies
        cookie_items = []
        cookie_array.each do |h|
          cookie_items << (h[:name] +'='+ h[:value])
        end
			 	cookie_items.join(';')
	  	end

  	  def is_frozen_page?
        @driver.url.include?('freeze')
      end

      def is_failed_login?
       	error_box = @driver.div :class => 'me'
      	error_box.exists? && error_box.text.include?("登录失败")     	
      end

      def is_blocked_page?
      	flag = false
        if @driver.url.include?('blocked')
        	error_box = @driver.div :class => 'c'
        	flag = true if error_box.exists? && error_box.text.include?("存在异常")
        end
        flag
      end

      def is_verification_page?
      	flag = false
        if @driver.url.include?('login.weibo.cn')
        	error_box = @driver.div :class => 'me'
        	flag = true if error_box.exists? && error_box.text.include?("验证码")
        end
        flag
      end

      def is_weibo_unexist_page?
      	error_box = @driver.div :class => 'me'
      	error_box.exists? && error_box.text.include?("微博不存在")
      end

	  	def destroy
	  		@driver.close
	  	end

	  	private
	  		def is_login_page?
	  			@driver.url.include?('login.weibo.cn')
	  		end


		  	# def get_account_for_test
	  	  #   Cook.new({:username => "zhouhualei@gmail.com", :passwd => "xinlang1988610"})
	    	# end

	      # def get_uid_for_test
	      # 	 1970299232 # darui
	      # end

	      # def get_weiboid_for_test
	      # 	"M_zqMBhyXky"
	      # end

	  end
  end
end
