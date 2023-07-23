function steamkill -d "Kill all steam instances"
   command ps ax | grep '[s]team' | awk '{ print $1 }' | xargs kill
end
