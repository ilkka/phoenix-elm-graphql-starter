port module Ports exposing (..)

-- Outbound ports


port push : String -> Cmd msg



-- Inbound ports


port socketStart : (String -> msg) -> Sub msg


port socketResult : (String -> msg) -> Sub msg


port socketCancel : (String -> msg) -> Sub msg


port socketAbort : (String -> msg) -> Sub msg


port socketError : (String -> msg) -> Sub msg
