function edit-remote
    set remote_file $argv[1]
    set local_file /tmp/(basename $remote_file)

    # Download the file
    scp $remote_file $local_file

    # Store the initial checksum of the file
    set initial_checksum (md5sum $local_file | awk '{print $1}')

    # Open the file in Helix
    hx $local_file

    # Calculate the checksum of the file after editing
    set final_checksum (md5sum $local_file | awk '{print $1}')

    # If the file was changed, upload it back to the remote server
    if test $initial_checksum != $final_checksum
        if scp $local_file $remote_file
            echo "File uploaded successfully."
            # If the upload was successful, delete the local file
            rm $local_file
        else
            echo "File upload failed."
        end
    else
        echo "File not changed."
    end
end
