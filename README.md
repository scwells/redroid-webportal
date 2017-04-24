# Redroid Video Streaming Server

The Redroid Video Streaming Server handles all video stream publishing and stored video management for the Redroid project.

### Technologies

  - Linux
  - Ruby on Rails
  - [NGINX + RTMP module](https://github.com/arut/nginx-rtmp-module)

### Thoughts on Security
All you need is the Peripheral Device ID to get to all your stored videos on the website. There is no login and password. This streaming server was originally intended to be run at your home for you to create your own personal security camera system using old Android phones via Redroid. With that said, we strongly suggest that you run this at your home on a Raspberry pi or something similar, and NOT open it up to the big scary internet.
  
### Installation Instructions
----
##### Note: There are plans in the future to make deploying this MUCH EASIER than the manual steps listed here. Probably with Docker. We may also provide a ready to go raspberry pi OS image that you can simply write to an sd card and you'll be ready to go. Until then, however, this is how you deploy the Redroid Video Streaming Server.
-----

#### You will need:
1. A linux box (this guide uses Ubuntu Server 16.04)
    - Can run on Raspberry pi! It runs surprisingly well. 
2. Some shell experience and router configuration knowledge
3. A lot of patience

### Step 1 -- Initial Setup
 Open terminal.
 Create new user redroid and set the password to whatever you want.
 ```sh 
 $ sudo useradd redroid
 $ sudo passwd redroid
 ```
 We need to add some folders in redroid home directory and set permissions to completely open.
 
 ```sh
 $ su redroid
 $ mkdir ~/motion_detection_images ~/video_saves && chmod 777 ~/motion_detection_images ~/video_saves
 $ mkdir ~/video_saves/vod_links && chmod 777 ~/video_saves/vod_links
 ```
 
 ### Step 2 --  NGINX + RTMP module
To complete this step, first follow the instructions outlined [here](https://www.vultr.com/docs/setup-nginx-rtmp-on-ubuntu-14-04).

We made changes to the nginx config file ``` /usr/local/nginx/conf/nginx.conf ``` in the tutorial. We need to change some things to make this config file work for Redroid. Replace the file with the following:

```sh
#user  nobody;
worker_processes  1;
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
        include       mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        #keepalive_timeout  0;
        keepalive_timeout  65;

        upstream upstream_server {
            server localhost:3000;
        }
        
        server {
            listen       80;
            server_name  my_site.local;

            location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_redirect off;
                proxy_pass http://upstream_server;
                break;
            }
        }
    }

rtmp {
    server {
            listen 1935;
            chunk_size 4096;

            application live_no_record {
                    live on;
                    record off;
                    exec ffmpeg -i rtmp://localhost/live/$name -threads 1 -c:v libx264 -profile:v baseline -b:v 350K -s 640x360 -f flv -c:a aac -ac 1 -strict -2 -b:a 56k rtmp://localhost/live360p/$name;
            }
            application live {
                    live on;
                    record all;
                    record_path /home/redroid/video_saves/;
                    record_suffix -%d-%b-%y-%T.flv;
                    drop_idle_publisher 5s;
                    exec ffmpeg -i rtmp://localhost/live/$name -threads 1 -c:v libx264 -profile:v baseline -b:v 350K -s 640x360 -f flv -c:a aac -ac 1 -strict -2 -b:a 56k rtmp://localhost/live360p/$name;
            }
            application live360p {
                    live on;
                    record off;
            }
            application vod {
                    play /home/redroid/video_saves/vod_links/;
            }
    }
}
```
Note: This file can be found in this project under the ```redroid-install``` folder.

This config file sets up nginx to do a number of things..
    - Automatically record all video streams to ```~/video_saves```
    - Reroute traffic recieved on port 80 to a rails app running internally on port 3000
    - Serve stored videos located in the ```vod_links``` folder.

Once that file is updated, restart nginx.
```sh
$ sudo service nginx restart
```
### Step 3 -- Video Indexer
#### What is it?
The video indexer is a python script whose job is to monitor the ```~/video_saves``` folder for new streaming videos. It completes the following:
  - Waits until a stream has stopped and injects metadata information into the ```.flv``` file. This is needed to enable video seeking to different times using the slider.
  - Moves video files into their corresponding peripheral folder.
    - Stored videos are sorted by the Peripheral device ID. i.e. ``` ~/video_saves/[DEVICE_ID]/video.flv```
- Creates symlinks in ```~/video_saves/vod_links``` . These are needed for NGINX to serve videos in the Redroid Video Portal.

#### To install
First make sure you have python 2.7 installed. 

Copy project folder ```redroid-fs-monitor``` into ```~/video_saves```

Install watchdog
```sh
$ sudo pip install watchdog
```

We will use supervisor to set up the indexer as a service.

```sh
$ sudo apt-get install supervisor
```

Copy file ```~/video_saves/redroid-fs-monitor/fs_monitor_supervisor.conf``` into ```/etc/supervisor/conf.d/```, update and start.

```sh
$ sudo cp ~/video_saves/redroid-fs-monitor/fs_monitor_supervisor.conf /etc/supervisor/conf.d/
$ sudo supervisor update
$ sudo supervisorctl start redroid-fs-monitor
```

You should then see ``` redroid-fs-monitor: started``` if everything was successful!


 ### Step 4 - Video Portal
 
 Follow the guide [here](https://gorails.com/setup/ubuntu/16.10 ) to set up Ruby on Rails (This may take a while).
 
 Once that is finished, navigate to ```~/redroid-webportal``` and start up the server
 
 ```sh
 $ cd ~/redroid-webportal
 $ bundle install
 $ rails db:migrate
 $ rails s
```
You should then (hopefully) see the server fire up. 

To back out use ``` Ctrl-C ``` to stop the server.

To make the server run in the background and detach from terminal, I like to use the ```screen``` utility.

```sh
$ cd ~/redroid-webportal
$ screen
$ rails s
```

Once the rails server is running type ```Ctrl-a``` and then ```d```. This will detach you from the terminal and have the server run in the background indefinitely. To reattach to the server in the terminal use

```sh
$ screen -r
```