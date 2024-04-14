function trim -d "Trims trailing whitespaces"
    if test (count $argv) -eq 0 ; or test "$argv[1]" = "-h"
        # Usage
        echo "Usage: trim [-c|--check] [FILE ...]"
        return -1
    end
    # Check if first argument is -c or --check
    if test "$argv[1]" = "-c" ; or test "$argv[1]" = "--check"
        set check 1
        set files $argv[2..-1]
    else
        set files $argv
        set check 0
    end
    # for each argument
    for file in $files
        if not test -f $file
            echo "trim: $file: Not a file"
            continue
        end
        if test $check -eq 1
            echo "Checking $file"
            command sed 's#\([[:space:]]\+$\)\|\( \+\t\)##g' $file | diff $file -
        else
            echo "Trimming $file"
            command sed -i 's#\([[:space:]]\+$\)\|\( \+\t\)##g' $file
        end
    end
end
