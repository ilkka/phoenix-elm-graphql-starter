port module Ports exposing (..)
import Json.Encode exposing (Value)

-- Outbound ports


type alias GraphQLRequest =
    { operation : String
    , variables : Value
    }


port push : GraphQLRequest -> Cmd msg



-- Inbound ports


port socketStart : (String -> msg) -> Sub msg


port socketResult : (String -> msg) -> Sub msg


port socketCancel : (String -> msg) -> Sub msg


port socketAbort : (String -> msg) -> Sub msg


port socketError : (String -> msg) -> Sub msg
