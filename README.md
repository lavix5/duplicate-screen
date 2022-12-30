# Duplicate screen script 

This is a script written in bash to duplicate screen when external display is connected. Script finds the highest common resolution and aplies it to both screens. When no external screen is plugged, it sets preffered resolution of laptop screen. It uses xrandr to do so. Adding udev rule allows to run this automatically when external screen is plugged and unplugged. Script is made to work with VGA or HDMI output. If you use other output, change script accordingly to what output you use.

### Dependencies :

  - xrandr
  
### Usage :

Clone the repo: 
```sh
$ git clone https://github.com/lavix5/duplicate-screen.git
```
Change Xauthority in duplicate_screen.sh script according to your $USERNAME, or if you don't have that file in your home, then search in display manager files.

```sh
$ export XAUTHORITY="/home/$USERNAME/.Xauthority"
```
Copy it to your desired location (eg, ~/.screenlayout/) and make it executable:
```sh
$ sudo chmod +x /location/to/script/duplicate_screen.sh
```
Check with udevadm monitor, if values in udev rule 99-duplicate-screen.rules are correct for your system (plug external screen after udevadm monitor). Change path to script after RUN+= to path you chosen to put the script into. Change ENV{XAUTHORITY} value to your .Xauthority file (same as in duplicate_screen.sh script). Lastly copy the rules file into /etc/udev/rules.d/
```sh
$ sudo cp 99-duplicate-screen.rules /etc/udev/rules.d/
```
Udev rules should be automatically be reloaded. If not, reload them:
```sh
$ sudo udevadm control --reload
```
Now:
  - when you plug external monitor, internal screen will be duplicated
  - when you unplug external monitor, internal screen will be set to preferred resolution.
