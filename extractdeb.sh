#!/bin/bash

# using this since docker cp doesn't currently support wildcards
sh -c "docker run -i mdsakalu/rpi-raspbian-ffmpeg /bin/tar -cv /root/packages" | tar x --strip-components=1
