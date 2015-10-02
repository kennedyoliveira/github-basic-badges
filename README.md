# GitHub Basic Badges

Basic badges for using with GitHub, and a service that you can deploy and create your own service to serve the GitHub badges.

## Motivation

I know there are alots of services that you can generate badges for GitHub, i just developed one more to play around with Ruby and Heroku.

### Badges

All the URL Patterns showed in the table bellow must be used as `<app-url>\<url-pattern>`.

| URL Pattern | Description | Preview |
| ----------- | ----------- | ------- |
| `downloads/<user>/<repo>/total.svg` | Sum of downloads of all artifacts in the latest release. | [![GitHub Download Count](https://github-basic-badges.herokuapp.com/downloads/kennedyoliveira/github-basic-badges/total.svg)]() |
| `downloads/<user>/<repo>/<tag>/total.svg` | Sum of downloads of all artifacts in the release with the `<tag>` | [![GitHub Download Count By Tag](https://github-basic-badges.herokuapp.com/downloads/kennedyoliveira/github-basic-badges/v1.0.0/total.svg)]() |
| `downloads/<user>/<repo>/<file>.svg` | Total downloads of the artifact named `<file>` in the latest release. | [![GitHub Download Count By Artifact](https://github-basic-badges.herokuapp.com/downloads/kennedyoliveira/github-basic-badges/dummy.txt.svg)]() |
| `downloads/<user>/<repo>/<tag>/<file>.svg` | Total downloads of an artifact named `<file>` in the release with a tag name `<tag>`. | [![GitHub Download Count By Artifact and Release](https://github-basic-badges.herokuapp.com/downloads/kennedyoliveira/github-basic-badges/v1.0.0/dummy.txt.svg)]() |
| `release/<user>/<repo>.svg` | Latest release tag name. | [![GitHub Release](https://github-basic-badges.herokuapp.com/release/kennedyoliveira/github-basic-badges.svg)]() |
| `issues/<user>/<repo>.svg` | Total issues open. | [![GitHub Issues Open](https://github-basic-badges.herokuapp.com/issues/kennedyoliveira/github-basic-badges.svg)]() |
| `commits/<user>/<repo>.svg` | Total commits. | [![GitHub Commits](https://github-basic-badges.herokuapp.com/commits/kennedyoliveira/github-basic-badges.svg)]() |

### Deploying on Heroku

Install heroku toolbet and log to it after that, it's pretty straigth forward deploying on heroku, just do the following:

````
# Cloning the repository
git clone https://github.com/kennedyoliveira/github-basic-badges.git
cd github-basic-badges

# Create a heroku app
heroku create

# Push the code to heroku
git push heroku master

# Open the app
heroku open
````

### Mine Heroku App

My instance is running in the following url `https://github-basic-badges.herokuapp.com` you can use it to generate badges for your repos!

If you have any question or suggestion, open an issue!
