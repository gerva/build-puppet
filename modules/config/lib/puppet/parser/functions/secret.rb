# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Puppet::Parser::Functions
  newfunction(:secret, :type => :rvalue, :arity => 1) do |args|
    name = args[0]
    aspects = lookupvar("aspects") || []
    aspects.inject(nil) do |_, aspect|
      begin
        break function_hiera(["#{name}!#{aspect}"])
      rescue Puppet::Error
        nil # ignore error
      end
    end || function_hiera([name])
  end
end
