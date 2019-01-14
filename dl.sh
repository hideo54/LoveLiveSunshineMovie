printf "This script requires curl and jq (and youtube-dl if you want videos). Run? [y/n] "
read input
if [ $input = 'y' ]
then
    if [ ! -e scenes.json ]
    then
        curl -s 'https://lovelive-sunshinemovie.jp/assets/json/scenes.json' > scenes.json
    fi

    printf "Do you want quoteImages? [y/n] "
    read areQuoteImagesNeeded
    if [ $areQuoteImagesNeeded = 'y' ]
    then
        if [ ! -e quoteImages/ ]
        then
            mkdir quoteImages
        fi
    fi

    printf "Do you want thumbnails? [y/n] "
    read areThumnailsNeeded
    if [ $areThumnailsNeeded = 'y' ]
    then
        if [ ! -e thumbnails/ ]
        then
            mkdir thumbnails
        fi
    fi

    printf "Do you want videos? (youtube-dl is required) [y/n] "
    read areVideosNeeded
    if [ $areVideosNeeded = 'y' ]
    then
        if [ ! -e videos/ ]
        then
            mkdir videos
        fi
    fi

    jq -c '.[]' scenes.json | while read i
    do
        n=`echo $i | jq -r '.id'`
        id=`printf %03d $n`
        quote=`echo $i | jq -r '.serif'`
        thumbnail=`echo $i | jq -r '.share_image'`
        videoId=`echo $i | jq -r '.youtube_link_id'`
        filename="${id}_${quote}"

        printf "\rProcessing ${id}/100…"

        if [ $areQuoteImagesNeeded = 'y' ]
        then
            curl -s "https://lovelive-sunshinemovie.jp/assets/images/txt/txt_${id}.png" > "quoteImages/${filename}.png"
        fi
        if [ $areThumnailsNeeded = 'y' ]
        then
            curl -s "https://lovelive-sunshinemovie.jp/iBbC2c2a92mPUeJM/${thumbnail}" > "thumbnails/${filename}.jpg"
        fi
        if [ $areVideosNeeded = 'y' ]
        then
            youtube-dl --quiet -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' "https://www.youtube.com/watch?v=${videoId}" -o "videos/${filename}.mp4"
        fi
    done
    echo ''
    echo 'done.'
else
    exit 0
fi
