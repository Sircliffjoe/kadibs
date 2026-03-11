# frozen_string_literal: true

# Configure Pagy for pagination
# See: https://ddnexus.github.io/pagy/

require "pagy/extras/overflow"
require "pagy/extras/metadata"
require "pagy/extras/headers"

Pagy::DEFAULT[:items] = 25        # Default items per page
Pagy::DEFAULT[:size]  = [ 1, 4, 4, 1 ] # Navigation bar size
Pagy::DEFAULT[:overflow] = :last_page # When page is out of range, show last page
