function clangfmt -d "Run clang-format in a git project"
    if not test -d .git -o -d .sl
        if test (count $argv) -ne 1
            echo "Not a git repo, --force must be used"
            return -1
        end
        switch $argv[1]
            case '-f' '--force'
            case '*'
                echo "Invalid Argument"
                return -1
        end
    end
    command fd -ec -eh -0 | xargs -0 -P $(nproc) -I % clang-format -i %
end
