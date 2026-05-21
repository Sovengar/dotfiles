function backup --argument filename --description 'Create a .bak copy of a file'
    if test -z "$filename"
        echo 'Usage: backup <filename>'
        return 1
    end

    cp $filename $filename.bak
end
