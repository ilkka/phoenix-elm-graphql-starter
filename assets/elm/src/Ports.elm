port module Ports exposing (..)

-- Outbound ports


port push : String -> Cmd msg


-- Inbound ports


port socketAbort : (String -> msg) -> Sub msg


port socketError : (String -> msg) -> Sub msg


port socketStart : (String -> msg) -> Sub msg


port socketResult : (String -> msg) -> Sub msg
