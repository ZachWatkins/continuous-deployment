# Constants
FOLDERNAME=repo-name
DIRECTORY=wp-content/themes
GIT_RELEASE_KEY=abcd1234
GIT_PUSH_SERVER=git@git.wpengine.com:production/install.git
GIT_PUSH_SERVER2=git@git.wpengine.com:production/install2.git

# Setup Commands
# Get around shallow update restriction
if [ -f ${HOME}/clone/.git/shallow ]; then git fetch --unshallow; fi
# Add User Data
git config --global user.name "codeship-repo-name"
git config --global user.email "watkinza@gmail.com"
git config --global github.token GIT_RELEASE_KEY
# Move repo files to a named folder
mkdir $FOLDERNAME
shopt -s extglob
mv !($FOLDERNAME) $FOLDERNAME
# Move repo files whose name begins with a period
mv .sass-lint.yml $FOLDERNAME/.sass-lint.yml
# Exclude development-only files from commit
rm .gitignore
mv .codeshipignore $FOLDERNAME/.gitignore
# Move named folder into a structure identical to the root directory of a WordPress server
mkdir -p $DIRECTORY
mv $FOLDERNAME $DIRECTORY
cd $DIRECTORY/$FOLDERNAME/

# Deployment commands
# Add servers
git remote add servers $GIT_PUSH_SERVER
git remote set-url --add --push servers $GIT_PUSH_SERVER
git remote set-url --add --push servers $GIT_PUSH_SERVER2
# Build
npm install
grunt
# Release
grunt release
# Deploy
git add --all :/
git commit -m "DEPLOYMENT"
git push servers HEAD:refs/heads/master --force
# Cache node_modules based on Codeship specifications
cd ../../../
mv $DIRECTORY/$FOLDERNAME/node_modules node_modules
