function doasedit -d "A sudoedit alternative for doas"
    set -l filename $argv[1]
    if test -z "$filename"
        echo "Usage: doasedit <file>"
        return 1
    end

    set -l filename (realpath $filename)
    
    set -l ext (path extension $argv[1])

    set -l editor $EDITOR
    if test -z "$editor"
        set -l editor vim
    end

    set -l tmpfile (mktemp --suffix=$ext --tmpdir doasedit.XXXXXXXXXX)
    if test -e $filename
        if not test -f $filename
            echo "doasedit: Cannot operate with non files"
            return 1
        end
        if not cp $filename $tmpfile
            echo "doasedit: Failed to copy file to temporary location"
            return 1
        end
    end

    $editor $tmpfile

    if not cmp -s $filename $tmpfile
        if not doas mv $tmpfile $filename
            echo "doasedit: Failed to move the modified temp file back to original location."
            echo "File still exists at: $tmpfile."
            return 1
        end
    else
        # No changes made, remove the temporary file
        rm $tmpfile
    end
end

