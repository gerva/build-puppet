# num_masters.rb
#
require 'facter'
Facter.add("num_masters") do
    setcode do
        Facter::Util::Resolution.exec('ls -1 /etc/default/buildbot.d 2>/dev/null | wc -l')
    end
end
