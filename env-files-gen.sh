FORCE="${FORCE:-0}"

for file in example-*.env; do
    dst_file=${file#*-}
    if [ -e $dst_file ] && [ "x${FORCE}" != "x1" ]; then
        echo File $dst_file already exists
    else
        echo Creating file $dst_file
        cp $file $dst_file
    fi
done
