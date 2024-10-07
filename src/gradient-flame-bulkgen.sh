#!/bin/bash
image1=$1

sizes=("1920x1080" "2560x1440" "1000x1000" "1000x1400")
cat gradients.json | jq -c '.[]' | while read gradient_data; do
    name=$(echo $gradient_data | jq -r '.name')
    colors=$(echo $gradient_data | jq -r '.colors | join("-")')
    color1=$(echo $gradient_data | jq -r '.colors[0]')
    color2=$(echo $gradient_data | jq -r '.colors[-1]')
    for size in "${sizes[@]}"; do
        width=$(echo $size | cut -d'x' -f1)
        height=$(echo $size | cut -d'x' -f2)
        magick -size $size gradient:"$colors" \
            -distort SRT -45 \
            \( +clone -fill none -stroke 'rgba(255,255,255,0.8)' -strokewidth 1 \
            -draw "roundrectangle 50,50 $((width-50)),$((height-50)) 50,50" \) \
            -compose over -composite -stroke none -fill gray \
            -gravity center -fill 'rgba(255,255,255,0.8)' -pointsize 80 \
            -annotate 0 "$name\n$size" \
            -gravity northwest -pointsize 40 \
            -annotate +10+10 "$color1" \
            -gravity southeast -pointsize 40 \
            -annotate +10+10 "$color2" \
            \( "$image1" -resize 200x -geometry +100%+100% \) -compose over -composite \
            "${name}_${size}.png"
    done
done
