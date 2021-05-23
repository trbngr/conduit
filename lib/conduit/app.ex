defmodule Conduit.App do
  use Commanded.Application,
    otp_app: :conduit,
    default_dispatch_opts: [
      returning: :aggregate_state
    ]

  router Conduit.Router
end
