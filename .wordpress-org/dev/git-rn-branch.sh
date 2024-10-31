# https://gist.github.com/lttlrck/9628955
old_branch=$1
new_branch=$2
if [ -z "$old_branch" -o -z "$new_branch" ]; then
  echo USAGE: `basename $0` old_branch new_branch
  exit
fi
git branch -m $old_branch $new_branch        # Rename branch locally    
git push origin :$old_branch                 # Delete the old branch    
git push --set-upstream origin $new_branch   # Push the new branch, set local branch to track the new remote
