function up
    if test -z "$argv"
        cd ..
    else
        switch $argv
            case '*'
                for i in (seq $argv)
                    cd ..
                end
        end
    end
end
