#!/bin/bash
sizes=("1920x1080" "2560x1440" "1000x1000" "1000x1400")
title="Title"
logo_image="logo.png"
cat gradients.json | jq -c '.[]' | while read gradient_data; do
    name=$(echo $gradient_data | jq -r '.name')
    colors=$(echo $gradient_data | jq -r '.colors | join("-")')
    color1=$(echo $gradient_data | jq -r '.colors[0]')
    color2=$(echo $gradient_data | jq -r '.colors[1]')
    color3=$(echo $gradient_data | jq -r '.colors[2]')
    for size in "${sizes[@]}"; do
        width=$(echo $size | cut -d'x' -f1)
        height=$(echo $size | cut -d'x' -f2)
        magick -size $size xc:none \
            -sparse-color Barycentric "0,0 $color1  $((width / 2)),$height $color2  $width,$((height / 2)) $color3" \
            \( +clone -background black -shadow 100x15+10+10 \) +swap -background none -layers merge +repage \
            \( +clone -fill none -stroke '#F5F5F5' -strokewidth 1 \
               -draw "roundrectangle 50,50 $(($width - 50)),$(($height - 50)) 50,50" \) \
            -gravity center -font "Helvetica-Bold" -fill '#F5F5F5' -pointsize 80 \
            -annotate +0+0 "$title" \
            -gravity center -fill '#F5F5F5' -pointsize 60 -annotate +0+100 "$name\n$size" \
            -gravity northwest -fill gray -pointsize 40 -annotate +10+10 "$color1" \
            -gravity southeast -fill gray -pointsize 40 -annotate +10+10 "$color2" \
            \( $logo_image -resize 100x100 \) \
            -gravity southeast -geometry +80+80 -composite \
                        "${name}_${size}.png"
    done
done