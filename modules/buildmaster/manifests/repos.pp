# buildmaster repo class
# creates the souce code repoitories
define buildmaster::repos($repo_name, $dst_dir) {

    $hg_repo = "http://hg.mozilla.org/build/$repo_name"

    exec {
        # make will take care of checking out
        # buildbotcustom and tools
        "clone-$repo_name-${dst_dir}":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File[$dst_dir],
            ],
            command => "/tools/python27-mercurial/bin/hg clone $hg_repo $dst_dir",
            user => "$users::builder::username";
    }
}
