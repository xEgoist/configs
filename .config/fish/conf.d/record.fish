function record -d "record screen using wf-recorder"
    # Function to generate a random filename
    function random_filename
        set uuid (uuidgen)
        echo "$uuid.mp4"
    end

    # Determine the output path
    set output_path ""
    if test (count $argv) -eq 0
        set output_path (random_filename)
        echo $output_path
    else
        set provided_path $argv[1]
        if test -d $provided_path
            set output_path "$provided_path/$(random_filename)"
        else if test -n (path extension $provided_path) -a -d (dirname $provided_path)
            set output_path $provided_path
        else
            echo "Invalid path: $provided_path" >&2
            return 1
        end
    end
    set output_path (path resolve $output_path)
    set -l DEFAULT_SINK_MONITOR "$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep "node\.name" | cut -d '=' -f2 | tr -d ' ' | cut -d '"' -f2).monitor"

    wf-recorder -f $output_path -c hevc_vaapi --audio="$DEFAULT_SINK_MONITOR" -d /dev/dri/renderD128 -F scale_vaapi=format=nv12:w=1920:h=1080
end
