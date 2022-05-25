# whee

whee is a command-line program to accelerate the GradleRIO deploy process used in the FIRST Robotics Competition. It automatically connects to available robot WiFi networks and deploys code.

> whee is still largely untested and is not approved or endorsed by FIRST in any way.

### known issues

- [ ] silently fails with networks that have not been connected to before, due to a profile matching the SSID not being present
- [ ] only works for windows cmd due to current reliance on netsh
