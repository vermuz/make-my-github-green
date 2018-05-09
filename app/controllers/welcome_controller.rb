class WelcomeController < ApplicationController

  # GET /welcome
  def index
  	authorize()
  end

  def authorize
  	if Rails.env == "development"
  		address = github.authorize_url scope: 'repo'
    	redirect_to address
  	elsif Rails.env == "production"
    	address = github.authorize_url redirect_uri: 'https://makemygithubgreen.herokuapp.com/callback', scope: 'repo'
    	redirect_to address
  	end
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

	    	contents = Github::Client::Repos::Contents.new oauth_token: @access_token.token

	    	file = contents.find user: 'alexandersideris', repo: 'repo-name', path: 'path'

			contents.update 'alexandersideris', 'repo-name', 'path',
			  path: '/',
			  message: 'Your commit message',
			  content: 'The contents to be updated',
			  sha: file.sha
	  	elsif e.is_a? Github::Error::ClientError
	  		puts 'client error'
	  	end
	end
	redirect_to "/success"  
  end

  def commit_and_push

  end

  private

   def github
    @github ||= Github.new client_id: '32f0ef2d0e2b2c581ce0', client_secret: '811d9f3565fab99b2acaefb43f4ae21430c433ac'
   end

end
