# Docker-nginx-rtmp
Docker image for an RTMP/HLS server running on nginx

* NGINX Version 1.21.1
* nginx-rtmp-module Version 1.2.2

## Configurations
This image exposes port 1935 for RTMP Steams and has 2 default channels open "live" and "testing".

live (or your first stream name) is also accessable via HLS on port 8080

It also exposes 8080 so you can access http://<your server ip>:8080/stat to see the streaming statistics.

The configuration file is in /opt/nginx/conf/

## Running

To run the container and bind the port 1935 to the host machine; run the following:
```
docker run -p 1935:1935 -p 8080:8080 jasonrivers/nginx-rtmp
```

### build Images

1. Build RTMP IMAGE

```
docker build  -t bishoyabdo/nginx-rtmp .

```
2. HLS IMAGE

```
docker build -f Dockerfile-hls -t bishoyabdo/nginx-hls .

```
### Multiple Streams:
You can enable multiple streams on the container by setting RTMP_STREAM_NAMES when launching, This is a comma seperated list of names, E.G.
```
docker run      \
    -p 1935:1935        \
    -p 8080:8080        \
    -e RTMP_STREAM_NAMES=live,teststream1,teststream2   \
    bishoyabdo/nginx-hls
```

### Pushing streams
You can ush your main stream out to other RTMP servers, Currently this is limited to only the first stream in RTMP_STREAM_NAMES (default is live) by setting RTMP_PUSH_URLS when launching, This is a comma seperated list of URLS, EG:
```
docker run      \
    -p 1935:1935        \
    -p 8080:8080        \
    -e RTMP_PUSH_URLS=rtmp://live.youtube.com/myname/streamkey,rtmp://live.twitch.tv/app/streamkey
    bishoyabdo/nginx-hls
```

## OBS Configuration
Under broadcast settings, set the follwing parameters:
```
Streaming Service: Custom
Server: rtmp://<your server ip>/live
Play Path/Stream Key: mystream
```

## Start docker containers 

1 . RTMP 


```
 docker run -it  --name nginx-rtmp2 -p 1935:1935  bishoyabdo/nginx-rtmp:latest
```

2. HLS

```
 docker run -it  --name nginx-rtmp2 -p 1935:1935 -p 8080:8080 bishoyabdo/nginx-hls:latest
```
## Watching the steam

In your favorite RTMP video player connect to the stream using the URL:
rtmp://&lt;your server ip&gt;/live/mystream
http://&lt;your server ip&gt;/hls/mystream.m3u8

## Tested players
 * VLC
 * omxplayer (Raspberry Pi)

## you can test by using 

```
git clone https://github.com/outcast/live-streaming-demo
~/live-streaming-demo
ffmpeg -re -i bbb_sunflower_1080p_60fps_normal.mp4 -vcodec copy -loop -1 -c:a aac -b:a 160k -ar 44100 -strict -2 -f flv http://57.79.252.84:8080/hls/bbb.m3u8
```

1. incase RTMP --> go to VLC --> network stream -->  rtmp://57.79.252.84/live/bbb

2. Incase HLS --> go to VLC --> network stream -->  http://57.79.252.84:8080/hls/bbb.m3u8
