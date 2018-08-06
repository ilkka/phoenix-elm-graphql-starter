port module Ports exposing (..)

import Json.Decode exposing (Value)


-- Outbound


{-| This type represents a request, either a query, mutation or subscription.
It can have variables.
-}
type alias GraphQLRequest =
    { tag : String -- our own tag that comes back in the response so we know how to decode
    , operation : String
    , variables : Value
    }


port send : GraphQLRequest -> Cmd msg


{-| This type describes a result being received from GraphQL.
The data member contains the result as a JSON encoded string,
and the tag member identifies the schema of the data so that an
appropriate decoder can be selected.
-}
type alias GraphQLResult =
    { tag : String -- the tag mirroring the one in the request
    , data : String -- JSON string with the actual data
    }


{-| This is the port that GraphQL results will come from.
-}
port receive : (GraphQLResult -> msg) -> Sub msg



-- Here are some generic housekeeping ports that can be subbed to to receive info about socket events


port socketStart : (String -> msg) -> Sub msg


port socketCancel : (String -> msg) -> Sub msg


port socketAbort : (String -> msg) -> Sub msg


port socketError : (String -> msg) -> Sub msg
