require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

# This task is the daily commits for free users
task :daily_commits => :environment do
  	# Get all the users
	users = User.all

	# Loop through them
	users.each do |user|

		# Create a random number of commits
		possible_number_of_commits = [0,0,0,1,2,3,4,5,6,7]
		random_index = rand(possible_number_of_commits.length)


		$i = 0
		$num = possible_number_of_commits[random_index]

		# Make the commits
		while $i < $num  do
		   new_commit(user)
		   $i +=1
		end

	end
end

def new_commit(user)

	# Get the GitHub instance
	github = Github.new oauth_token: user.github_authentication_token

  	# Get the repo we have created, hopefully. I could just access user.repo_name but he might have deleted or changed the name
	uri = URI('https://api.github.com/user/repos?access_token='+user.github_authentication_token)
	response = JSON.parse(Net::HTTP.get(uri))
	
	response.each do |repo|
		if repo['name'] == user.repo_name
				
			# Make a commit
			    
		    file = github.repos.contents.find user: user.github_username, repo: user.repo_name, path: 'README.md'
				
			github.repos.contents.update user.github_username, user.repo_name, 'README.md',
				path: 'README.md',
				message: 'Small change',
				content: 'This is the GitHub Gardener project',
				sha: file.sha
				
			break
		end
	end
end