# build-rpi-ffmpeg
This docker image will compile ffmpeg for the Raspberry Pi. It compiles ffmpeg with x264 and libv4l. Other libraries for things like aac audio could be added as well.
You might need to install qemu-user-static and copy qemu-arm-static from your machine to the root of the repo in order to build.

```
cp $(which qemu-arm-static) .
```

You can get the x264 and ffmpeg package files from the image with `extractdeb.sh` if that's all you care about.