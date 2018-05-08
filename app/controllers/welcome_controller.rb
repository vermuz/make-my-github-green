class WelcomeController < ApplicationController

  # GET /welcome
  def index
  	authorize()
  end

  def authorize
    address = github.authorize_url scope: 'repo'
    redirect_to address
  end

  def callback
  	begin
  		authorization_code = params[:code]
	    @access_token = github.get_token authorization_code
	    @access_token.token
	    github = Github.new oauth_token: @access_token.token
	    github.repos.create name: 'repo-name'
	rescue Github::Error::GithubError => e
	  	puts e.message
	  	if e.is_a? Github::Error::ServiceError
	    	puts 'service error'
	    	github.repos.contents.create 'alexandersideris', 'repo-name', 'path',
			  path: 'hello.rb',
			  content: "puts 'hello ruby'",
			  message: "my commit message"
	  	elsif e.is_a? Github::Error::ClientError
	  		puts 'client error'
	  	end
	end
	# redirect_to "/success_page"  
  end

  def commit_and_push

  end

  private

   def github
    @github ||= Github.new client_id: '32f0ef2d0e2b2c581ce0', client_secret: '811d9f3565fab99b2acaefb43f4ae21430c433ac'
   end

end
