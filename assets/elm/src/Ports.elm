port module Ports exposing (..)

import Json.Decode exposing (Value, map2, field, string)


-- Outbound ports


type alias GraphQLRequest =
    { id : String -- our own identifier that comes back in the response so we know how to decode
    , operation : String
    , variables : Value
    }


port push : GraphQLRequest -> Cmd msg



-- Inbound ports


type alias GraphQLResult =
    { id : String -- the identifier mirroring the one in the request
    , data : String -- JSON string with the actual data
    }


resultDecoder : Json.Decode.Decoder GraphQLResult
resultDecoder =
    map2 GraphQLResult
        (field "id" string)
        (field "data" string)


port socketStart : (String -> msg) -> Sub msg


port socketResult : (Value -> msg) -> Sub msg


port socketCancel : (String -> msg) -> Sub msg


port socketAbort : (String -> msg) -> Sub msg


port socketError : (String -> msg) -> Sub msg
