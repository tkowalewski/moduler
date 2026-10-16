module Moduler
  module Profile
    module Sessions
      class RevocationController < ApplicationController
        def destroy
          Current.user.sessions.active.update_all(signed_out_at: Time.current)
          cookies.delete(:session_id)

          redirect_to moduler.new_session_path, status: :see_other
        end
      end
    end
  end
end
