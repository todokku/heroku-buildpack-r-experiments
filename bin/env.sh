# set path for testing within docker container
export PATH="/app/bin:/app/R/lib/R/bin:/app/tcltk/bin:$PATH"

# resolve R libs
export LD_LIBRARY_PATH="/app/R/lib/R/lib:/app/tcltk/lib"

# set R profile for site
export R_PROFILE="/app/R/etc/Rprofile.site"

# default language
export LANG=${LANG:-C.UTF-8}

# default timezone
export TZ=${TZ:-UTC}
