Overview
--------

I'm a student of the [Ruhr Universität Bochum](http://www.ruhr-uni-bochum.de) in Germany and in all student dormitories ran by the [AKAFÖ](http://www.akafoe.de/wohnen/wohnheime/) are provided with a free highspeed internet connection by [highspeedsurfer.de](http://www.highspeedsurfer.de).

However it is necessary that you log yourself in via a service website on <http://login.rz.ruhr-uni-bochum.de> in order to get this internet connection. Unfortunately this login system kicks you out after 30mins of not using your internet connection. I'm really not sure how this 'inactivity' is determined. But it seems that at least `ping google.de` in an infinite loop isn't enough to convince the server that you're still using your internet connection.

Since I'm a nerd I've also a linux-based router running with OpenWRT and I really don't want to visit this login page every little while to refresh the internet link and stuff like that. That's why I've written this litte script that you can put into your crontab and stay logged in 24h a day / 7days a week. So no nasty surprises when you're on the road and try to login via VNC just to notice that your internet connection was already cut off.


How does it work
----------------

What this script basically does is:

1. Check if your gateway is reachable (there might be a problem with your network in general, in this case `exit 1`)
2. Check if we can ping something on the internet - I'm using google.de for that - if yes everything is fine we can `exit 0` if not:
3. Use curl to send the form data via HTTP POST like if you would have logged in yourself via browser.


Install
-------

I'm using this on my OpenWRT router, but if you want to use this for your Linux server it will work in the same way.

1. Download the rub-login.sh and place it somewhere on your harddrive like `/usr/bin`
2. Edit your crontab file, which is for OpenWRT `/etc/crontabs/root` and add the following line:

```
*/1 * * * * /usr/bin/rub-login.sh
```

This will execute the script every minute, so if you get kicked out of your internet it, you'll be offline for max. 1 minute. On OpenWRT you'll also have to enable the cron daemon. You can find how to do that [here](http://wiki.openwrt.org/doc/howto/notuci.config#etccrontabsroot).