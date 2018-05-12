# GitHub Gardener

A simple web app that commits code to your GitHub repo in order to make your contribution history green.

http://www.githubgardener.xyz

## Permissions

For this project to work, I needed to access the 'repo' scope. That means read and write permissions.

I don't abuse any of these permissions, I don't even store you email. All I do is store your GitHub username because I have to.

## Web flow

When you sign up, GitHub Gardener creates new public repo for you with a README.md file.  

I create a new User model consisting of you github username, the authentication token the GitHub API sends back to me and the name of the new repo. 

Then, everyday, GitHub Gardener loops through the users and commits a 'change' to the README.md file a random number of times. subset = [0,7]

That's it.

## Delete account / Unsubscribe

You can also always unsubscribe. Go to githubgardener.xyz, click Sign Up with GitHub and then on the /success page click on the 'Delete my GitHub Gardener account' button.

## Progress

You can view the whole progress of GitHub Gardener from idea inception to Product Hunt launch on this thread. (https://twitter.com/alexsideris_/status/993523095708332032). If there is anything new, I will post it there.
