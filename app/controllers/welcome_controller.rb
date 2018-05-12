class WelcomeController < ApplicationController

  # Homepage
  def index
  end

  # This is called by the 'Sign Up with GitHub' buttons
  def signup
  	authorize()
  end

  def authorize
  	if Rails.env == "development"
  		address = github.authorize_url scope: 'repo'
    	redirect_to address
  	elsif Rails.env == "production"
    	address = github.authorize_url redirect_uri: 'http://www.githubgardener.xyz/callback', scope: 'repo'
    	redirect_to address
  	end
  end

  # This is called by the GitHub API after user agrees to authorize the app. It is also called when he clicks 'Sign Up with Github', even if he has already authorize it
  def callback
  	begin

  		# Get the authentication token
  		authorization_code = params[:code]
	    @access_token = github.get_token authorization_code
	    @access_token.token
		
		# Get GitHub username
		uri = URI('https://api.github.com/user?access_token='+@access_token.token)
		response = JSON.parse(Net::HTTP.get(uri))
		username = response['login']

		github = Github.new oauth_token: @access_token.token

	    # Create the new User if he isn't doesn't already exist, else update the authentication token
	    user = User.where(:github_username => username).first

	    if user == nil

	    	# Create new user
	    	user = User.new(:github_username => username, :github_authentication_token => @access_token.token)
	    	user.save

	    	create_repo_and_initial_commit(username, @access_token.token, github)

	    else

	    	# Update authentication token
	    	user.github_authentication_token = @access_token.token
	    	user.save

	    end

	# Catch error so that the page does not return a 500 error
	rescue Github::Error::GithubError => e
	  	puts e.message
	  	if e.is_a? Github::Error::ServiceError
	    	puts 'service error'
	  	elsif e.is_a? Github::Error::ClientError
	  		puts 'client error'
	  	end
	end

	redirect_to "/success"  
  
  end

  def camo
  	
  end

  private

  	def create_repo_and_initial_commit(username, token, github)


		# Create a repo, github-gardener + UTC timestamp to be sure the name does not exist
		repo_name = 'github-gardener'
	    github.repos.create name: repo_name

	    # Update repo_name field
	    user = User.where(:github_username => username).first
	    user.repo_name = repo_name
	    user.save

	    # Create a new file, README.md and commit
	    github.repos.contents.create username, user.repo_name, 'README.md',
			  path: 'README.md',
			  message: 'Initial commit',
			  content: "This is the GitHub Gardener project"

  	end

   def github
   	
   	# Instantiate 'GitHub Gardener'
   	# For development purposes, I have two apps, 'Get GitHub Gardener' and 'Get GitHub Gardener Dev'
   	
   	if Rails.env == "development"
    
    	# Get GitHub Gardener Dev
    	@github ||= Github.new client_id: '32f0ef2d0e2b2c581ce0', client_secret: '811d9f3565fab99b2acaefb43f4ae21430c433ac'
  	
  	elsif Rails.env == "production"
    	
    	# Get GitHub Gardener
    	@github ||= Github.new client_id: '32f0ef2d0e2b2c581ce0', client_secret: '811d9f3565fab99b2acaefb43f4ae21430c433ac'
  	
  	end
   end

end
