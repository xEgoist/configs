function betterfox -d "Update betterfox (modify the firefox dir below in case of custom profile)"
    command curl -s https://raw.githubusercontent.com/yokoffing/Betterfox/master/user.js -o ~/.mozilla/firefox/*.default/user.js
end
